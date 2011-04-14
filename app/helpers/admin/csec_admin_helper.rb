module SurveyData
  class Importer
    require 'csv'

    ##
    # Import from CSV
    ##
    def self.import(type, file, commit=false, is_ta=nil)
      results = { :errors => [], :info => [] }
      result = []
      last_row = ["none", 0]

      results[:info] << "Save = #{!!commit}" if commit

      [:instructors, :klasses, :instructorships, :courses].each {|s| ActiveRecord::Base.connection.execute "ANALYZE #{s.to_s};"}

      begin
        ActiveRecord::Base.transaction do
          state = :init
          frequency_keys = {}
          current = {}

          CSV.open(file.path, 'r', ',') do |row|
            next if row.compact.empty?
            last_row = [row.join(' '), last_row[1]+1] unless last_row[0].eql? row.join(' ')
            # puts "Entering state #{state.to_s}"

            case state
            when :init:
              # Initialize vars that are cross-state, but not cross-klass
              frequency_keys = []   # Ordered list of [1], [2], N/A, ...
              frequencies = {}      # Frequencies that will go into SurveyAnswer
              result = []           # For convenience, will be appended to results[:info] at :finish state
              current = {:course     => {},
                         :klass      => {},
                         :instructor => {},
                         :instructorship => {},
                         :answers    => []
                        }            # Cross-state state
              state = :accept_klass
              redo
            when :accept_klass:
              # Row like
              # ["EE 100-1 NIKNEJAD,ALI (prof)", "60 RESPONDENTS", nil, nil, nil, nil, nil, nil, nil, nil, nil, "FALL 2010", nil] 
              
              row.compact!
              s = row.shift.upcase.split /\s+/

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
              course = Course.find_by_prefix_and_course_number_and_suffix_and_department_id(c[:prefix], c[:course_number], c[:suffix], c[:department_id]) || Course.new(c)

              raise if k[:section].blank?
              # REVELATION: currently, all TAs are globbed into a single section, and sections differentiate instructors.
              # FIXME: make default section nil, instead of 0.
              ### k[:section] = k[:section].blank? ? 0 : k[:section].to_i 
              k[:section] = 0 unless course.course_number % 100 == 94
              k[:section] = k[:section].to_i
              k[:course_id] = course.id || 'OMGWTFBBQ'
              klass = Klass.find(:first, :conditions=>k) || Klass.new(k)
              klass.course = course

              # Instructor
              i[:title] = (s.last =~ /\(\w+\)/) ? s.pop.to_s[1..-2] : 'PROF'  # (prof) => prof
              i[:private] = true #false if i[:title] =~ /prof/i
              i[:title] = {'PROF'=>'Professor', 'TA'=>'Teaching Assistant'}[i[:title]]
              i[:last_name], i[:first_name] = s.join(' ').split(',').collect(&:strip).collect(&:titleize_with_dashes)
              instructor = Instructor.find(:first, :conditions => ['last_name LIKE ? AND first_name LIKE ?', i[:last_name], i[:first_name]]) || Instructor.new(i)

              # Instructorship
              instructorship = Instructorship.find_by_klass_id_and_instructor_id(klass.id, instructor.id) || Instructorship.new
              #instructorship.instructor, instructorship.klass = instructor, klass  # NOTE this doesn't work, idk why
              instructorship.ta = (is_ta.nil? ? !(i[:title] =~ /prof/i) : is_ta)
              #instructorship.klass = klass

              [:course, :klass, :instructor].each do |o|
                m = binding.eval o.to_s
                next if m && m.valid?
                results[:errors] << "Invalid #{o.to_s}: #{m.inspect}"
                state = :error
              end
              redo if state == :error

              result << "#{course.course_abbr}-#{klass.section}, #{klass.proper_semester}"
              [:course, :klass, :instructor, :instructorship].each do |s|
                o = binding.eval s.to_s
                pfix = (o.created_at.nil? ? '::NEW::' : 'existing')
                result << ["#{pfix} #{s.to_s.capitalize}", [o.inspect]]
                current[s] = o
              end

              raise unless [current[:course], current[:klass], current[:instructor], current[:instructorship]].all?

              if commit then
                [klass, course, instructor, instructorship].each do |o|
                  instructorship.instructor, instructorship.klass = instructor, klass # wtf man
                  next if o.save
                  results[:errors] << "Failed to save #{o.inspect} because #{o.errors.inspect}"
                  raise "save failed"
                end
              end

              state = :frequencies

            when :frequencies:
              row.compact!
              next if row.first =~ /FREQUENCIES/i
              row.each do |k|
                case
                when k =~ /\[(.+)\]/:
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
		qtext = $1.gsub(/[^a-zA-Z]/,' ')
		q = SurveyQuestion.find_by_text(qtext) || SurveyQuestion.search {keywords qtext}.results.first
		q = nil if !q || !SurveyQuestion.exists?(q.id)
                unless q
                  results[:errors] << "Couldn't find survey question matching \"#{qtext}\"... check spelling and perhaps do a find+replace to correct it."
                  state = :error
                  redo
                end
                a = {}
                a[:survey_question_id] = q.id
                a[:instructorship_id] = current[:instructorship].id
                row.shift # question text
                a[:frequencies] = Hash[frequency_keys.zip frequency_keys.collect{row.shift.to_i}]
                a[:frequencies] = ActiveSupport::JSON.encode a[:frequencies]
                a = SurveyAnswer.find(:first, :conditions=>a) || SurveyAnswer.new(a)

                if commit
                  if a.save
                    a.order = current[:answers].length+1
                    a.recompute_stats!  # only do for commit because new klasses will cause null constraint errors
                  else
                    results[:errors] << "Error with survey answer #{a.inspect}"
                    state = :error
                  end
                end

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
      rescue => e
        results[:errors] << "Error #{e.inspect} parsing near line #{last_row[1]}: #{last_row[0]}"
        results[:errors] << ["Stack trace:", e.backtrace]
        #raise if RAILS_ENV.eql?('development')
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
