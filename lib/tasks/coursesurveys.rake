require 'csv'

LECTURE_COURSE_MATCH = Admin::CsecAdminHelper::Importer::LECTURE_COURSE_MATCH
DISC_COURSE_MATCH = Admin::CsecAdminHelper::Importer::DISC_COURSE_MATCH
SKIPPED_QUESTIONS = Admin::CsecAdminHelper::Importer::SKIPPED_QUESTIONS
QUESTION_MAPPING = Admin::CsecAdminHelper::Importer::QUESTION_MAPPING

def parse_header(header)
  if SKIPPED_QUESTIONS.key?(header)
    return header
  end

  # Remove '- Mean' or '(Mean)' suffixes
  header.sub!(/ -? \(?Mean\)?/, '')

  # Shorten long headers
  if QUESTION_MAPPING.key?(header)
    header = QUESTION_MAPPING[header]
  end

  # Find matching question in database, complain if not found
  question = SurveyQuestion.find_by(text: header) || SurveyQuestion.search {keywords header} .results.first
  if question.nil?
    raise ParseError, "No SurveyQuestion with name '#{header}' in database"
  end
  return question
end

def parse_semester(semester)
  sem = Klass.semester_code_from_s(semester)
  if sem.nil?
    raise ParseError, "Semester not recognized. Expected in format: 'Fall 20XX', 'Spring 20XX', 'Summer 20XX'"
  end
  return sem
end

def find_dept(dept_abbr)
  dept = Department.find_by_nice_abbr(dept_abbr)
  if dept.nil?
    raise ParseError, "Invalid department '#{dept_abbr}' in row '#{row}'"
  end
  return dept
end

def find_course(dept, number, commit=false)
  prefix, course_number, suffix = Course.split_course_number(number, {hash: false})
  course_hash = {
    prefix: prefix,
    course_number: course_number,
    suffix: suffix,
    department_id: dept.id
  }
  course = Course.find_by(course_hash) || Course.new(course_hash)
  if commit and not course.save
    raise ParseError, "Course save failed: #{course.inspect}"
  end
  return course
end

def find_klass(section, course, semester, commit=false)
  klass_hash = {section: section, course_id: course.id, semester: semester}
  klass = Klass.find_by(klass_hash)
  if klass.nil?
    klass = Klass.new(klass_hash)
    klass.course = course
    if commit and not klass.save
      raise ParseError, "Created new class from survey, but save failed: #{klass.inspect}"
    end
  end
  return klass
end

def find_instructor(first_name, last_name, is_ta, commit=false)
  instructor = Instructor.where(
    "UPPER(last_name) LIKE ? AND UPPER(first_name) LIKE ?",
    last_name.upcase,
    first_name.upcase
  ).order(created_at: :desc).first
  if instructor.nil?
    # We can create klasses/TAs,
    # but creating professors leads to pain with typos
    if is_ta
      instructor = Instructor.new({
        private: true,
        title: 'Teaching Assistant',
        last_name: last_name,
        first_name: first_name
      })
      if commit and not instructor.save
        raise ParseError, "Created new (TA) Instructor, but save failed: #{instructor.inspect}"
      end
    else
      puts "Could not find Instructor '#{first_name}, #{last_name}' in database"
      # raise ParseError, "Could not find Instructor '#{first_name}, #{last_name}' in database"
    end
  end
  return instructor
end

def find_instructorship(instructor, klass, is_ta, commit=false)
  iship = Instructorship.find_by(klass: klass, instructor: instructor)
  if iship.nil? and not (instructor.nil? or klass.nil?)
    iship = Instructorship.new(ta: is_ta, instructor_id: instructor.id, klass_id: klass.id)
    if commit and not iship.save
      raise ParseError, "Instructorship save failed: #{instructorship.inspect}, errors: #{instructorship.errors.inspect}"
    end
  end
  return iship
end

def make_survey_answer(instructorship, question, attrs, order, commit=false)
  if instructorship.nil?
    puts "Instructorship not found"
    return
  end
  answer_hash = { survey_question_id: question.id, instructorship_id: instructorship.id }
  a = SurveyAnswer.find_by(answer_hash) || SurveyAnswer.new(answer_hash)
  a.mean = attrs[:mean]
  a.frequencies = attrs[:frequencies]
  a.enrollment = attrs[:enrollment]
  a.num_responses = attrs[:responses]
  p a
  if commit
    if a.save
      a.order = order
      return a
    else
      raise ParseError, "Error with survey answer #{a.inspect}"
    end
  end
end

namespace :coursesurveys do
  # rake coursesurveys:scrape["<url>","<full course names to permit>"]
  desc "Scrape a schedule.berkeley.edu url into this semester's course surveys to be surveyed"
  task :scrape, [:url, :permit] do |t, args|
    #   The permit option is for courses which need to be specifically included
    #   due to not having a lecture (such as 61AS).  Should be of the format
    #   "COMPUTER SCIENCE 61AS, COMPUTER SCIENCE 375". Leave as "" if none
    # - For url, do a search on schedule.berkeley.edu (e.g. for EE or CS department)
    #   and take that url. (Should be osoc.berkeley.edu/...)
    # - Some instructors may not be auto-identified. Instead manually search for IDs in the rails console:
    #   $ Instructor.where(last_name: "<name>").take
    unless url = args.url
      puts "Enter the schedule.berkeley url"
      url = $stdin.readline.strip
    end
    permit = args.permit
    puts "Importing from #{url}..."
    importer = CourseSurveys::ScheduleImporter.new(url, permit)
    importer.import!
  end

  # rake coursesurveys:import["<csv>", <true/false>, <cols>...]
  task :import, [:semester, :ta, :commit] do |t, args|
    # require Admin::CsecAdminHelper::Importer
    file = ENV["FROM"]
    if ENV.key?("COLS")
      cols = ENV["COLS"].split(',').map{|c| c.to_i}
    else
      cols = nil
    end
    semester = parse_semester(args.semester)
    ta = args.ta.to_s == 'true'
    commit = args.commit.to_s == 'true'

    csv = CSV.open(file, "r:bom|utf-8",
                   headers: true, 
                   header_converters: lambda {|header| parse_header(header)})

    csv.each do |row|
      # ignore response rate
      # name, first_name, last_name, uid, enrollment, responses, response_rate, *ratings = row
      _, name = row.delete("Courses - Name")
      _, first_name = row.delete("Instructors - First Name")
      _, last_name = row.delete("Instructors - Last Name")
      _, _uid = row.delete("UID")
      _, enrollment = row.delete("Invited Count")
      _, responses = row.delete("Response Count")
      _, _response_rate = row.delete("Response Rate")

      # Prepare to create survey answers
      course = name.match(LECTURE_COURSE_MATCH)
      if course.nil?
        course = name.match(DISC_COURSE_MATCH)
        if course.nil?
          raise ParseError, "First element in spreadsheet at row #{row} did not match lecture or discussion format. Make sure it is something like 'EL ENG 00A LEC 001 COURSE NAME HERE' (may or may not have section number)"
        end
        dept_abbr, course_number, type, long_name = course.captures
        section = "1"
      else
        dept_abbr, course_number, type, section, long_name = course.captures
      end

      section = section.to_i
      enrollment = enrollment.to_i
      responses = responses.to_i

      if last_name.blank? or first_name.blank?
        raise ParseError, "Professor/T.A. '#{first_name}, #{last_name}' does have a first/last name in row #{row}"
      end

      instructor = find_instructor(first_name, last_name, ta)
      dept = find_dept(dept_abbr)
      course = find_course(dept, course_number)
      klass = find_klass(section, course, semester)
      instructorship = find_instructorship(instructor, klass, ta)

      order = 1
      row.each do |entry|
        question, rating = entry
        # If non-question entries (name, course, etc), parsing failed
        if question.instance_of?(String)
          raise ParseError, "Unexpected question: #{question}"
        end
        if cols.nil? || cols.include?(question.id)
          attrs = {
            mean: rating.to_f,
            frequencies: '{}',
            enrollment: enrollment,
            responses: responses
          }
          make_survey_answer(instructorship, question, attrs, order, commit)
          order += 1
        end
      end
    end
  end
end
