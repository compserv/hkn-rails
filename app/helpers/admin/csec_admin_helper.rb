module SurveyData
  class Importer
    require 'csv'

    ##
    # Import from CSV
    ##
    def self.import(type, file, commit=false)
      results = { :errors => [], :info => [] }
      result = []
      last_row = ["none", 0]

      begin
        ActiveRecord::Base.transaction do
          state = :init
          frequency_keys = {}
          current = {}

          CSV.open(file.path, 'r', ',') do |row|
            next if row.compact.empty?
            last_row = [row.join(' '), last_row[1]+1] unless last_row[0].eql? row.join(' ')
            puts "Entering state #{state.to_s}"

            case state
            when :init:
              # Initialize vars that are cross-state, but not cross-klass
              frequency_keys = []   # Ordered list of [1], [2], N/A, ...
              frequencies = {}      # Frequencies that will go into SurveyAnswer
              state = :accept_klass
              result = []
              current = {:course     => {},
                         :klass      => {},
                         :instructor => {},
                         :answers    => []
                        }
              redo
            when :accept_klass:
              # Row like
              # ["EE 100-1 NIKNEJAD,ALI (prof)", "60 RESPONDENTS", nil, nil, nil, nil, nil, nil, nil, nil, nil, "FALL 2010", nil] 
              
              row.compact!
              s = row.shift.split /\s+/

              c = current[:course    ]  # course
              k = current[:klass     ]  # klass
              i = current[:instructor]  # instructor

              # Course, klass
              c[:abbr] = s.shift
              c[:number], k[:section] = s.shift.split '-'   # 100-1 => [100, 1]
              k[:semester] = Klass.semester_code_from_s(row.pop)

              if dept = Department.find_by_nice_abbr(c[:abbr]) then
                c.delete :abbr
                c[:department_id] = dept.id
              else  # no dept found
                results[:errors] << "Couldn't find #{c[:abbr]} dept"
                state = :error
                redo
              end

              c.merge! Course.split_course_number(c.delete(:number))
              course = Course.find(:first, :conditions=>c) || Course.new(c)

              k[:section] = k[:section].blank? ? nil : k[:section].to_i 
              k[:course_id] = course.id
              klass = Klass.find(:first, :conditions=>k) || Klass.new(k)

              # Instructor
              i[:title] = s.pop.to_s[1..-2]  # (prof) => prof
              i[:last_name], i[:first_name] = s.first.split(',').collect(&:titleize)
              instructor = Instructor.find :first, :conditions => ['last_name LIKE ? AND first_name LIKE ?', i[:last_name], i[:first_name]]

              [course, klass, instructor].each do |o|
                next if o.valid?
                results[:errors] << "Invalid model: #{o.inspect}"
                state = :error
                redo
              end

              result << "#{course.course_abbr}-#{klass.section}, #{klass.proper_semester}"
              result << ["Course: #{course.inspect}"]
              result << ["Klass: #{klass.inspect}"]

              current[:klass] = klass
              current[:course] = course
              current[:instructor] = instructor
              state = :frequencies

            when :frequencies:
              row.compact!
              next if row.first =~ /FREQUENCIES/i
              row.each do |k|
                case
                when k =~ /\[(.+)]/:
                  k = $1
                  redo
                when k.is_int? || k =~ /N\/A|Omit/:
                  frequency_keys.push k
                else next  # ignore stats, these are recomputed
                end # row case
              end # row.map
              # result << ["Read frequency keys:", frequency_keys]
              state = :data

            when :data:
              case
              when row.first =~ /^[A-Z ]+$/:        # e.g. CLASSROOM PRESENTATION
              when row.first =~ /^\d\. (.+)/:    # question data
                unless q = SurveyQuestion.find_by_text($1)
                  results[:errors] << "Couldn't find survey question matching \"#{$1}\"... check spelling and perhaps do a find+replace to correct it."
                  state = :error
                  redo
                end
                a = {}
                a[:survey_question_id] = q.id
                a[:klass_id] = current[:klass][:id]
                a[:instructor_id] = current[:klass][:instructor_id]
                row.shift # question text
                a[:frequencies] = Hash[frequency_keys.zip frequency_keys.collect{row.shift.to_i}]

                current[:answers] << a
              when row.first =~ /^1 is a low rating/:
                # Example scoring
              when row.first =~ /^Data processed/:
                # end of klass
                result << ["Survey responses:", current[:answers]]
                state = :finish
                redo
              else
                state = :error
                redo
              end
              state = :data   # process moar

            when :finish:
              results[:info] << result.dup
              state = :init

            when :error:
              raise
            end # case state
          end # CSV.open
        end # transaction
      rescue
        results[:errors] << "Error parsing near line #{last_row[1]}: #{last_row[0]}"
      end

      return results
    end # import
  end # Importer
end # SurveyData

module Admin
 module CsecAdminHelper
   include SurveyData
 end
end
