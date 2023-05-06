module SurveyData
  class Importer
    require 'csv'

    LECTURE_COURSE_MATCH = /([A-Z ]+) (\w+) (\w+) (\d+) (.+)/
    DISC_COURSE_MATCH = /([A-Z ]+) (\w+) (\w+) (.+)/
    QUESTION_MAPPING = {
      "Considering both the limitations and possibilities of the subject matter and course, how would you rate the overall teaching effectiveness of this instructor?" => "Rate the overall teaching effectiveness of this instructor",
      "The instructor’s lectures, facilitation of classes, and/or office hours and help sessions enhanced my learning." => "Rate the overall teaching effectiveness of this instructor",
      "Focusing now on the course content, how worthwhile was this course in comparison to others you have taken in this department?" => "How worthwhile was this course compared with others at U.C.?",
      "How worthwhile was this course in comparison to others you have taken at this university?" => "How worthwhile was this course compared with others at U.C.?",
      "Overall teaching effectiveness" => "Rate the T.A.'s overall teaching effectiveness",
      "The GSI’s instructional activities, contributions, and/or feedback enhanced my learning." => "Rate the T.A.'s overall teaching effectiveness",
    }
    SKIPPED_QUESTIONS = {
      "Courses - Name" => true,
      "Instructors - First Name" => true,
      "Instructors - Last Name" => true,
      "UID" => true,
      "Invited Count" => true,
      "Response Count" => true,
      "Response Rate" => true
    }

    # Imports all of the course surveys from the specified file. Commits
    # only if COMMIT is true.
    def self.import(file, semester, commit=false, is_ta=false)
      results = { errors: [], info: [] }
      rows = CSV.read(file.path, 'rb:bom|utf-8')
      header = rows.first

      header.each_with_index do |header_item, index|
        header[index].slice!(' - Mean') if header_item.end_with? ' - Mean'
        header[index].slice!(' (Mean)') if header_item.end_with? ' (Mean)'
      end

      semester = Klass.semester_code_from_s(semester)
      raise ParseError, "Semester not recognized, should be in one of the formats: 'Fall 20XX', 'Spring 20XX', 'Summer 20XX'" if semester.nil?

      log = []
      begin
        ActiveRecord::Base.transaction do
          # Go through all rows but the first one (contains the header information)
          rows.drop(1).each do |row|
            data = self.parse_row(row, header, semester, is_ta, log)
            self.save_survey(*data) if commit
          end
        end
      rescue ParseError => e
        results[:errors] = [e.message]
        return results
      end

      results[:info] = ["Successfully imported course surveys."] + log
      return results
    end

    # Takes a row from the course evaluation csv and extracts ratings.
    # Appends log output to LOG.
    def self.parse_row(row, header, semester, is_ta, log)
      # Remove 7 headers (class name, first name, last name, uid, invited count, response count, response rate)
      rating_names = header.drop(7)
      name, first_name, last_name, uid, enrollment, responses, _, *ratings = row

      match = name.match(LECTURE_COURSE_MATCH)
      if match.nil?
        match = name.match(DISC_COURSE_MATCH)

        if match.nil?
          raise ParseError, "First element in spreadsheet at row #{row} did not match lecture or discussion format. Make sure it is something like 'EL ENG 00A LEC 001 COURSE NAME HERE' (may or may not have section number)"
        end

        dept_abbr, course_number, type, long_name = match.captures
        section = "1"
      else
        dept_abbr, course_number, type, section, long_name = match.captures
      end

      if rating_names.length != ratings.length
        raise ParseError, "Ratings and header information do not match, got #{rating_names.length} header names but #{ratings.length} ratings in row #{row}"
      end

      section = section.to_i
      enrollment = enrollment.to_i
      responses = responses.to_i

      if last_name.blank? or first_name.blank?
        raise ParseError, "Professor/T.A. '#{first_name}, #{last_name}' does have a first/last name in row #{row}"
      end

      instructor = Instructor.where(['UPPER(last_name) LIKE ? AND UPPER(first_name) LIKE ?',
                                    last_name.upcase, first_name.upcase])
                             .order(created_at: :desc)
                             .first
      if instructor.nil?
        # We can create klasses/TAs, but creating professors leads to pain with typos
        if is_ta
          instructor = Instructor.new({ private: true, title: 'Teaching Assistant', last_name: last_name, first_name: first_name })
        else
          raise ParseError, "Could not find professor/T.A. '#{first_name}, #{last_name}' in database (from row #{row})"
        end
      end

      dept = Department.find_by_nice_abbr(dept_abbr)
      if dept.nil?
        raise ParseError, "Invalid department '#{dept_abbr}' in row '#{row}'"
      else
        dept_id = dept.id
      end

      survey_answers = []

      rating_names.zip(ratings).each do |rating_name, rating|
        next if rating.blank?

        if QUESTION_MAPPING.keys.include? rating_name
          name = QUESTION_MAPPING[rating_name]
        else
          name = rating_name
        end

        question = SurveyQuestion.where({ text: name }).first || SurveyQuestion.search { keywords name }.results.first
        raise ParseError, "Could not find survey question '#{name}' in database (from row #{row})" if question.nil?

        survey_answers << [question.id, { mean: rating.to_f, frequencies: '{}', enrollment: enrollment, responses: responses }]
      end

      log << "Parsed #{instructor.first_name} #{instructor.last_name} #{is_ta ? '(TA)' : '(Professor)'} " +
             "teaching section #{section} of #{course_number}."

      return semester, dept_id, course_number, section, instructor, is_ta, survey_answers
    end


    # Given some relevant data about a course survey, validates the survey,
    # and saves it if COMMIT is true. Make sure arguments match the return values of self.parse_row (above)
    def self.save_survey(semester, dept_id, course_number, section, instructor, is_ta, survey_answers)
      prefix, course_number, suffix = Course.split_course_number(course_number, {hash: false})
      course_hash = {prefix: prefix, course_number: course_number, suffix: suffix, department_id: dept_id}
      course = Course.where(course_hash).first || Course.new(course_hash)
      raise ParseError, "Course save failed: #{course.inspect}" if not course.save

      klass_hash = {section: section, course_id: course.id, semester: semester}
      klass = Klass.where(klass_hash).first || Klass.new(klass_hash)
      klass.course = course
      raise ParseError, "Klass save failed: #{klass.inspect}" if not klass.save

      if not Instructor.exists?(instructor.id)
        raise ParseError, "Instructor save failed: #{instructor.inspect}" if not instructor.save
      end

      instructorship = Instructorship.where(klass_id: klass.id, instructor_id: instructor.id).first || Instructorship.new
      instructorship.ta, instructorship.instructor, instructorship.klass = is_ta, instructor, klass
      raise ParseError, "Instructorship save failed: #{instructorship.inspect}, errors: #{instructorship.errors.inspect}" if not instructorship.save

      order = 1
      survey_answers.each do |pair|
        qid, attrs = pair
        answer_hash = { survey_question_id: qid, instructorship_id: instructorship.id }
        a = SurveyAnswer.where(answer_hash).first || SurveyAnswer.new(answer_hash)
        a.mean = attrs[:mean]
        a.frequencies = attrs[:frequencies]
        a.enrollment = attrs[:enrollment]
        a.num_responses = attrs[:responses]

        if a.save
          a.order = order
          order += 1
        else
          raise ParseError, "Error with survey answer #{a.inspect}"
        end
      end
    end
  end

  class ParseError < StandardError
  end
end

module Admin
  module CsecAdminHelper
    include SurveyData
  end
end
