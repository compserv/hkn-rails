module SurveyData
  class Importer
    require 'csv'
    require 'json'

    QMATCH = /\A\d\. (.+)/
    PROF_FREQUENCY_KEYS = ['1', '2', '3', '4', '5', '6', '7', 'N/A', 'Omit']
    TA_FREQUENCY_KEYS = ['1', '2', '3', '4', '5', 'N/A', 'Omit']
    INFO_EXAMPLE = "[\"EE 100-1 HILFINGER,PAUL N. (prof)\", \"60 RESPONDENTS\", nil, nil, nil, nil, nil, nil, nil, nil, nil, \"FALL 2010\", nil]"

    # Imports all of the course surveys from the specified file. Commits
    # only if COMMIT is true.
    def self.import(file, commit=false, is_ta=false)
      is_ta = is_ta.nil? ? false : true
      results = { :errors => [], :info => [] }
      rows = CSV.read(file.path)
      [:instructors, :klasses, :instructorships, :courses].each {|s| ActiveRecord::Base.connection.execute "ANALYZE #{s.to_s};"}

      log = []
      begin
        ActiveRecord::Base.transaction do
          while true
            data = self.next_survey(rows, is_ta, log)
            break if data.nil?
            semester, dept_id, course_number, section, instructor, survey_answers = data
            self.save_survey(semester, dept_id, course_number, section, instructor, survey_answers, is_ta) if commit
          end
        end
      rescue ParseError => e
        results[:errors] = e.message + ["Example: #{INFO_EXAMPLE}"]
        return results
      end

      results[:info] = ["Successfully imported course surveys."] + log
      return results
    end

    # Returns all the relevant data for the next survey in ROWS, or nil
    # if the file ends before then. Appends log output to LOG.
    def self.next_survey(rows, is_ta, log)
      survey_row = self.next_row(rows)
      return nil if survey_row.nil?

      survey_info = survey_row.compact
      semester = Klass.semester_code_from_s(survey_info.pop) # fall 2010

      course_info = survey_info.shift.downcase.split /\s+/
      dept_abbr = course_info.shift # EE
      course_number, section = course_info.shift.split '-' # 100-1 => [100, 1]
      raise ParseError, "No section listed in: #{survey_info}" if section.blank?
      section = section.to_i

      #course_info now e.g. ["HILFINGER,PAUL", "N.", "(prof)"]
      course_info.pop
      instructor_name = course_info.join(" ")
      last_name, first_name = instructor_name.split(',').collect(&:titleize_with_dashes)
      instructor = Instructor.find_by(['last_name LIKE ? AND first_name LIKE ?', last_name, first_name])
      if instructor.nil? # We can create klasses/TAs, but creating professors leads to pain with typos
        if is_ta
          instructor = Instructor.new({title: 'ta', private: true, title: 'Teaching Assistant',
            last_name: last_name, first_name: first_name})
        else
          raise ParseError, "Professor F:#{first_name}, L:#{last_name} does not exist in: #{survey_row}"
        end
      end

      row = self.next_row(rows)
      survey_answers = []
      while not self.contains(row, "data processed")
        #"1. Rate the overall teaching effectiveness of this instructor",1,7,22,27,57,30,12,,3,4.7,1.3,5
        row_data = row.dup
        qtext = row_data.shift
        if qtext =~ QMATCH
          qtext = qtext.match(QMATCH).captures[0]
        else
          raise ParseError, "Invalid survey question format: '#{qtext}' (expected '1. blah blah') in #{row}"
        end

        question = SurveyQuestion.where({text: qtext}).first || SurveyQuestion.search {keywords qtext}.results.first
        raise ParseError, "Invalid survey question '#{qtext}' in #{row}" if question.nil?

        frequencies = {}
        keys = is_ta ? TA_FREQUENCY_KEYS : PROF_FREQUENCY_KEYS
        keys.each do |key|
          frequencies[key] = row_data.shift.to_i
        end
        survey_answers << [question.id, frequencies.to_json]
        row = self.next_row(rows)
      end

      dept = Department.find_by_nice_abbr(dept_abbr)
      if dept.nil?
        raise ParseError, "Invalid department #{dept_abbr} in: #{survey_row}"
      else
        dept_id = dept.id
      end

      log << "Parsed #{instructor.first_name} / #{instructor.last_name} teaching " +
             "section #{section} of #{course_number}."

      return semester, dept_id, course_number, section, instructor, survey_answers
    end

    # Given some relevant data about a course survey, validates the survey,
    # and saves it if COMMIT is true.
    def self.save_survey(semester, dept_id, course_number, section, instructor, survey_answers, is_ta)
      prefix, course_number, suffix = Course.split_course_number(course_number, {hash: false})
      course_hash = {prefix: prefix, course_number: course_number, suffix: suffix, department_id: dept_id}
      course = Course.where(course_hash).first || Course.new(course_hash)
      raise ParseError, "Course save failed: #{course.inspect}" if not course.save

      klass_hash = {:section => section, :course_id => course.id, :semester => semester}
      klass = Klass.where(klass_hash).first || Klass.new(klass_hash)
      klass.course = course
      raise ParseError, "Klass save failed: #{klass.inspect}" if not klass.save

      raise ParseError, "Instructor save failed: #{instructor.inspect}" if not instructor.save

      instructorship = Instructorship.where(klass_id: klass.id, instructor_id: instructor.id).first || Instructorship.new
      instructorship.ta, instructorship.instructor, instructorship.klass = is_ta, instructor, klass
      raise ParseError, "Instructorship save failed: #{instructorship.inspect}" if not instructorship.save

      order = 1
      survey_answers.each do |pair|
        qid, frequencies = pair
        answer_hash = {survey_question_id: qid, instructorship_id: instructorship.id}
        a = SurveyAnswer.where(answer_hash).first || SurveyAnswer.new(answer_hash)
        a.frequencies = frequencies
        if a.save
          a.order = order
          order += 1
          a.recompute_stats!  # only do for commit because new klasses will cause null constraint errors
        else
          raise ParseError, "Error with survey answer #{a.inspect}"
        end
      end
    end

    # Returns the next relevant row, or nil if the file ends before then.
    def self.next_row(rows)
      row = rows.shift
      while row != nil and self.skippable(row)
        row = rows.shift
      end
      return row
    end

    # Returns true if a row has no relevant content.
    def self.skippable(row)
      if self.contains(row, "data processed")
        return false
      elsif row.compact.length <= 1
        return true
      elsif self.contains(row, "omit")
        return true
      else
        return false
      end
    end

    def self.contains(row, text)
      row = row.collect {|x| x.nil? ? "" : x}
      return row.sum.downcase.include? text
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

