# Parses a schedule.berkeley query into an internal data structure,
# for use in dumping Courses, Klasses, and Coursesurveys.
#
# CAUTION: This script is not for the faint of heart.
#          Proceed at your own risk.
#
# - jonathanko

require 'open-uri'

module CourseSurveys

  class ScheduleImporter

    class ImportError < StandardError; end
    class SkipKlass < StandardError; end
    class ValidationFailedError < StandardError; end
    class CourseMissingError < ImportError
      attr_reader :klass
      def initialize(x)
        @klass = x
        if x.is_a? Hash
          x = "#{x['Course'][:name]} #{[x[:prefix],x[:course_number],x[:suffix]].join}"
        end

        super(x)
      end
    end
    class InstructorMissingError < ImportError
      attr_reader :klass, :guesses

      # @param k [Hash] internal klass data structure
      # @param guesses [Array<Instructor>] [optional] potential matches
      def initialize(k,guesses=nil)
        @klass = k
        @guesses = guesses
        super(k['Instructor'])
      end
    end

    module Regex
      CourseName = /(.*) [PS] ([^\s]+) (.*)/  # COMPUTER SCIENCE C61C S 001 LEC
      Location   = /(.*),\s+(.*)/             # Tu 4-6P, 310 SODA
      Enrollment = /\s*([^:]*):(\d+)/         # Limit:20 Enrolled:9 Waitlist:2 Avail Seats:11
    end

    DefaultOptions = {
      :ignore      => [:lab, :dis, :rec, :ind],
      :interactive => true
    }

    PendingCommitOrder = [
      :courses, :klasses, :instructors, :instructorships, :coursesurveys
    ]

    # Department model
    attr_accessor :department

    def initialize(url, options={}, *args)
      require 'nokogiri'
      require 'open-uri'

      @url     = url

      @klasses = []
      @current_klass = nil
      @semester = nil
      @pending_commits = {
        :courses => [],
        :klasses => [],
        :instructors => [],
        :instructorships => [],
        :coursesurveys => []
      }

      @debug   = true
      @verbose = true

      @options = DefaultOptions.merge(options)

    end

    # Check, run, and save.
    def import!
      check_arguments!
      run || raise(ImportError)
      save!
    end

    private

    # Validates arguments, and raises if any don't pass.
    def check_arguments!
      raise ArgumentError.new("Specify schedule.berkeley URL") unless @url
    end

    # Process a key-value pair for some class
    # @param item [String, Symbol] Class datum key, or :start / :end to begin / save out current klass
    def process(item, value=nil)
      case item
      when :start
        @current_klass = {}
      when :end
        unless @current_klass.empty?
          puts @current_klass.inspect,'-'*80 if @verbose

          # Skip or add the current_klass
          skip = false
          skip ||= ((type = @current_klass["Course"][:type]) and @options[:ignore].include?(type.to_sym))
          skip ||= ((@current_klass['Restrictions'] =~ /not open/i) or @current_klass['Enrollment'][:limit] == 0)
          skip ||= (@current_klass['Location'] =~ /cancelled/i)
          skip ||= (@current_klass['Status/Last Changed'] =~ /cancelled/i)
          if skip
            puts "Skipping #{@current_klass.inspect}"
          else
            @klasses << @current_klass
          end
        end

        @current_klass = nil
      when nil
        raise ImportError.new("nil item")
      else

        if value
          value.gsub!(/\&nbsp;?/,'')     # idk how this happens
          value.gsub!(/^\"|\"$/,'')      # strip leading/trailing quotes

          # special handling
          case item
          when 'Course'
            name, section, type = value.scan(Regex::CourseName).first

            raise ImportError.new("Unknown name/type/section #{value}") unless [name, section, type].all?

            raise "section wtf #{section}" if section.to_i == 0
            value = {
                      :name => name,
                      :section => section.to_i,
                      :type => type.downcase.to_sym
            }

          when 'Location'
            time, location = value.scan(Regex::Location).first
            if time and location
              @current_klass['Time'] = time
              value = location.titleize
            end

          when /^Enrollment/
            item = 'Enrollment'
            h = {}
            value.scan(Regex::Enrollment).each do |cat, n|
              h[cat.split.first.downcase.to_sym] = n.to_i
            end
            value = h

          when 'Note'
            # Extract more instructors
            if also = value.scan(/Also: (.+)/).first
              instructors = also.split('; ').reject {|x| x =~ Regex::Location}
            end

          end
        end

        @current_klass[item] = value
      end
    end

    # Parses the selected schedule into an internal data structure.
    def run
      orig_url = @url
      orig_u = URI(@url)
      start_row = 1

      while @url
        u = URI(@url + "&p_start_row=#{start_row}")
        u.scheme ||= orig_u.scheme
        u.host ||= orig_u.host
        puts u.to_s
        content = open(u.to_s).read
        doc = Nokogiri::HTML(content)

        #If 100 divides the number of classes, schedule.berkeley.edu hilariously lets you browse one more
        #page than normal (the last page being empty), so we should break on that last page.
        if content.include? "Number of rows provided is out of the range of rows found"
          puts "No content found."
          break
        end

        # SCHEDULE.BERKELEY IS THE MOST HORRIBLY STRUCTURED WEB PAGE EVER OMFG

        doc.xpath('//body/table').each_with_index do |klass_table, i_table|
          if i_table == 0   # dumb header gif table
            @semester ||= Property.parse_semester(klass_table.at_xpath('./tr[2]/td/font/b').text.strip)
            next
          end

          process(:start)

          klass_table.xpath('.//tr').each do |tr|
            begin
              next unless tr.xpath('td[@colspan]').empty?
              item, value = tr.xpath('td[not(@rowspan)]')    # WTF SERIOUSLY

              # process item
              item = item.at_xpath('./font/b')

              # last row, which contains forms for getting the next page
              # of results or submitting a new search
              if not item
                item = tr.xpath('td/font/form/label/b')
                value = item[0]
              else
                begin
                  item = item.text[0..-3]   # WTH IS THAT CHARACTER AT THE END
                rescue => fuckaduck         # WHY DOESNT THE OTHER RESCUE WORK FOR THIS LINE
                  puts "fuckaduck"
                  #exit
                end
              end

              # process value
              value = value.text.strip
              value = nil if value.empty?

              if value =~ /next results/
                start_row += 100
                puts "Moving to next page" if @debug
              elsif value =~ /new search/
                # no next results, but has new search. must be last page.
                @url = nil
              else
                process(item,value)
              end

              # puts item, value
              # puts '-'*80
            rescue => e
              raise ImportError.new("Error when parsing #{tr}:\n  #{e.inspect}")
            end
          end

          process(:end)
        end
      end

      @url = orig_url
    end

    # Tidies up a url
    def tidy_url(u)
      u.strip!

      # Make sure stray slashes get escaped
      stuff = u.split('?')
      uri, form = stuff.first, stuff[1..-1].join('%3f')
      { '/'=>'%2f', ' '=>'+' }.each_pair do |c,u|
        form = form.gsub(c, u)
      end
      u = [uri,form].join('?')

      return u
    end
    
    # Commits internal data to the database.
    def save!
      #Coursesurvey.transaction do
        @klasses.each_with_index do |klass, i_klass|
          begin
            #puts "#{i.to_s.rjust 4}. #{klass.inspect}" if @debug

            # Find department, course
            dept, prefix, num, suffix = klass['Course'][:name].scan( /(.*) ([A-Z]*)(\d+)([A-Z]*)/ ).first
            num = {:prefix => prefix, :course_number => num.to_i, :suffix => suffix}
            dept   = Department.find_by_name(dept.titleize)
            klass[:num] = num
            klass[:dept] = dept
            course = dept.courses.where(num).first

            unless course
                course = intervene CourseMissingError.new(klass)
            end
            @pending_commits[:courses] |= [course]
            raise ImportError.new("nil course") unless course

            # Klass
            #k = Klass.find_or_initialize_by_course_and_semester_and_section(course, @semester, klass['Course'][:section])
            k = (!course.new_record? and Klass.find_by_course_id_and_semester_and_section(course.id, @semester, klass['Course'][:section]) ) || begin
            #if k.new_record?
              k = Klass.new
              k.course   = course
              k.semester = @semester
              k.section  = klass['Course'][:section]
              k.location = klass['Location']
              k.time     = klass['Time']
              k.notes    = klass['Note']
              k.num_students = klass['Enrollment'][:enrolled]
              #k.valid? || raise(ImportError.new(k.errors.inspect))
              k
            end
            puts "Using #{k.inspect}" if @debug
            @pending_commits[:klasses] |= [k]

            # Instructors
            # TODO add all of them (from Notes too)
            i = guess_instructor(klass['Instructor'])
            unless i.is_a? Instructor
              i = intervene InstructorMissingError.new(klass,i)
            end
            @pending_commits[:instructors] |= [i]

            # Instructorships
            iship = (!k.new_record? and !i.new_record? and Instructorship.find_by_klass_id_and_instructor_id(k.id, i.id)) || begin
              iship = Instructorship.new
              iship.klass  = k
              iship.instructor = i
              iship.ta = false
              iship
            end
            #iship.valid? || raise(ImportError.new(iship.errors.inspect))
            @pending_commits[:instructorships] |= [iship]

            # Coursesurvey
            c = (!k.new_record? and Coursesurvey.find_by_klass_id(k)) || begin
              c = Coursesurvey.new
              c.klass = k
              c
            end
            c.max_surveyors ||= 2
            c.status ||= 0
            #c.valid? || raise(ImportError.new(c.errors.inspect))
            @pending_commits[:coursesurveys] |= [c]

            puts c.inspect if @debug

          rescue SkipKlass
            puts "Skipping klass #{klass.inspect}", '-'*20
            @klasses.delete_at(i_klass)
            next
          rescue => e
            puts "Failed to process #{klass.inspect}:\n  #{e.inspect}"
            puts "klass: #{k.inspect}", "course: #{k && k.course.inspect}", "coursesurvey: #{c.inspect}"
            raise
          end # b-r-e
        end # each

        Coursesurvey.transaction do
          puts "Attempting to commit..."
          commit!
        end
      #end # transaction
    end

    # Attempt to resolve a problem.
    # If @options[:interactive] is set, user is prompted for resolution.
    # Otherwise, raise an error.
    # Raises an error if the situation cannot be resolved.
    # @param potential_error [ImportError] error to raise in the event this situation can't be handled
    # @return [Object,nil] context-dependent return value
    def intervene(potential_error)
      raise potential_error unless @options[:interactive]

      puts '-'*80,"Encountered error for:\n  #{potential_error.klass}" rescue nil

      case potential_error

      when CourseMissingError
        c = nil
        already = @pending_commits[:courses].select do |cc|
          x = potential_error.klass
          x[:dept] == cc.department and [:prefix, :course_number, :suffix].all?{|s|x[:num][s]==cc.send(s)}
        end.first
        return already if already
        UI::menu "Missing course #{potential_error.message}", [
          'Quit',
          'Automatically create it',
          "Skip klass #{potential_error.message}-#{potential_error.klass[:section]}"
        ] do |choice|
          case choice
          when 1
            raise potential_error
          when 2
            c = course_from_klass potential_error.klass
            (c and c.valid?) or raise ImportError.new("Create failed: #{c.errors.inspect}\n  for: #{c.inspect}")
            puts "*** Course saved: #{c.inspect}"
            return c # return value of intervene
          when 3
            raise SkipKlass
          else
            false
          end
        end
        return nil

      when InstructorMissingError
        i = nil
        dc = 3  # num extra choices
        UI::menu "Indecisive instructor guess: #{potential_error.klass['Instructor']} for #{potential_error.klass['Course'][:name]}",
          [
            'Quit',
            'Manual',
            "Skip klass #{potential_error.klass[:name]}-#{potential_error.klass[:section]}",
            *(potential_error.guesses.collect(&:full_name))
          ] do |choice|
          case choice
          when 1
            raise potential_error

          when 2
            iid = UI::request("Instructor id").to_i
            i = Instructor.find(iid)
            puts i.full_name
            if UI::confirm("Correct?")
              return i
            else
              false
            end

          when 3
            raise SkipKlass

          when (1+dc)..(potential_error.guesses.count+dc)
            chosen = potential_error.guesses[choice-1-dc]
            puts chosen.full_name
            return chosen
          else
            false
          end
        end # menu
        return nil

      when ValidationFailedError
        UI::menu "#{potential_error}",
          [
            'Quit',
            "That's okay, continue anyways"
          ] do |choice|
          case choice
          when 1
            raise potential_error
          when 2
            puts "Skipping validation error..."
            true # continue
          else
            false
          end
        end
        return nil

      # Unhandled error
      else
        puts "*** Could not intervene for #{potential_error.class} ***"
        raise potential_error.inspect
      end
    end

    # Convert a parsed klass Hash into a Course
    # @param klass [Hash] internal klass data structure
    # @return [Course]
    def course_from_klass(klass)
      c = Course.new
      dname, c.prefix, c.course_number, c.suffix = klass['Course'][:name].upcase.scan(/(.*) ([A-Z]*)(\d+)([A-Z]*)/).first
      c.course_number = c.course_number.to_i
      c.name = klass['Course'][:name]
      c.units = klass['Units/Credit'].scan(/\d+/).max.to_i

      raise ImportError.new("Unable to find department #{dname} (#{klass['Course'][:name]})") unless d = Department.find_by_name(dname.titleize)
      c.department_id = d.id
      return c
    end

    # Guess an instructor from the schedule.berkeley format
    # @param name [String] LAST NAME, F M
    # @return [Instructor, Array<Instructor>] Confident match for instructor, or Array of potentials in case of ambiguity
    def guess_instructor(name)
      return [] unless name
      begin
      lname, fi = name.upcase.scan(/([A-Z]+), ([A-Z])/).first.collect(&:titleize)
      rescue
        puts "*** FAILED parsing instructor name '#{name}'"
      end

      guesses = Instructor.where(last_name: lname)

      case

      # One matching last name & first initial
      when guesses.count == 1 && guesses.first.first_name.first == fi
        return guesses.first

      # Multiple matching last names
      when guesses.count > 1
        guesses = guesses.select {|i| i.first_name.first == fi}
        return guesses.first if guesses.count == 1

      end

      # Return best guesses
      return guesses
    end

    def commit!
       PendingCommitOrder.each do |s|
         @pending_commits[s].each do |m|
           case s
           when :klasses
             m.course_id = m.course.id
           when :instructorships
             m.klass_id = m.klass.id
           when :coursesurveys
             m.klass_id = m.klass.id
           end

           m.save || intervene(ValidationFailedError.new("Validation failed for #{m.inspect}\n  #{m.errors.inspect}"))
           puts m.inspect
         end
       end
    end

  end # ScheduleImporter

end # CourseSurveys
