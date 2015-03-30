module SurveyData
  class Importer
    require 'csv'

    QMATCH = /\A\d\. (.+)/
    FREQUENCY_KEYS = ['1', '2', '3', '4', '5', '6', '7', 'N/A', 'Omit']

    # Imports all of the course surveys from the specified file. Commits
    # only if COMMIT is true.
    def self.import(uh_FIXME, file, commit=false, is_ta=false)
      is_ta = is_ta.nil? ? false : true
      results = { :errors => [], :info => [] }
      rows = CSV.read(file.path)
      [:instructors, :klasses, :instructorships, :courses].each {|s| ActiveRecord::Base.connection.execute "ANALYZE #{s.to_s};"}

      begin
        ActiveRecord::Base.transaction do
          while true
            data = self.next_survey(rows)
            break if data.nil?
            semester, dept_id, course_number, section, instructor, survey_answers = data
            self.save_survey(semester, dept_id, course_number, section, instructor, survey_answers, is_ta, commit)
          end
        end
      rescue ParseError => e
        results[:errors] = e.message
        return results
      end

      results[:info] = ["Successfully imported course surveys."]
      return results
    end

    # Returns all the relevant data for the next survey in ROWS, or nil
    # if the file ends before then.
    def self.next_survey(rows)
      # ["EE 100-1 NIKNEJAD,ALI (prof)", "60 RESPONDENTS", nil, nil, nil, nil, nil, nil, nil, nil, nil, "FALL 2010", nil] 
      survey_row = self.next_row(rows)
      return nil if survey_row.nil?

      survey_info = survey_row.compact
      semester = Klass.semester_code_from_s(survey_info.pop) # fall 2010

      course_info = survey_info.shift.downcase.split /\s+/
      dept_abbr = course_info.shift # EE
      course_number, section = course_info.shift.split '-' # 100-1 => [100, 1]
      raise ParseError, "No section listed in: #{survey_info}" if section.blank?
      section = section.to_i

      instructor_name = course_info.shift #niknejad,ali
      last_name, first_name = instructor_name.split(',').collect(&:titleize_with_dashes)
      instructor = Instructor.find_by(['last_name LIKE ? AND first_name LIKE ?', last_name, first_name])
      if instructor.nil? # We can create classes, but creating instructors leads to pain with typos
        raise ParseError, "Instructor F:#{first_name}, L:#{last_name} does not exist in: #{survey_row}"
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

        question = SurveyQuestion.find_by_text(qtext) || SurveyQuestion.search {keywords qtext}.results.first
        raise ParseError, "Invalid survey question '#{qtext}' in #{row}" if question.nil?

        frequencies = {}
        FREQUENCY_KEYS.each do |key|
          frequencies[key] = row_data.shift.to_i
        end
        frequencies = ActiveSupport::JSON.encode frequencies
        survey_answers << [question.id, frequencies]
        row = self.next_row(rows)
      end

      dept = Department.find_by_nice_abbr(dept_abbr)
      if dept.nil?
        raise ParseError, "Invalid department #{dept_abbr} in: #{survey_row}"
      else
        dept_id = dept.id
      end

      puts "Loaded #{instructor}"

      return semester, dept_id, course_number, section, instructor, survey_answers
    end

    # Given some relevant data about a course survey, validates the survey,
    # and saves it if COMMIT is true.
    def self.save_survey(semester, dept_id, course_number, section, instructor, survey_answers, is_ta, commit)
      prefix, course_number, suffix = Course.split_course_number(course_number, {hash: false})
      course = Course.where({prefix: prefix, course_number: course_number, suffix: suffix, department_id: dept_id}).first || Course.new(c)
      course_id = course.id

      klass = Klass.find_by({:section => section, :course_id => course_id, :semester => semester}) || Klass.new(k)
      klass.course = course

      instructorship = Instructorship.find_by_klass_id_and_instructor_id(klass.id, instructor.id) || Instructorship.new
      instructorship.ta, instructorship.instructor, instructorship.klass = is_ta, instructor, klass
      puts "NEW INSTRUCTORSHIP #{instructorship.inspect} WITH #{is_ta}"

      [course, klass, instructor, instructorship].each do |o|
        if o.nil? or not o.valid?
          raise ParseError, "Invalid object to save: #{o.inspect}"
        end
      end

      return if not commit

      [klass, course, instructor, instructorship].each do |o|
        if not o.save
          raise ParseError, "Save failed: #{o.inspect}"
        end
      end

      survey_answers.each do |pair|
        qid, frequencies = pair
        a = SurveyAnswer.find_by({:survey_question_id => qid, :instructorship_id => instructorship.id}) || SurveyAnswer.new(a)
        a.frequencies = frequencies
        if a.save
          a.order = current[:answers].length + 1
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