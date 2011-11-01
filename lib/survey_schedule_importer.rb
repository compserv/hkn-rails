# Parses a schedule.berkeley query into an internal data structure,
# for use in dumping Courses, Klasses, and Coursesurveys.
#
# CAUTION: This script is not for the faint of heart.
#          Proceed at your own risk.
#
# - jonathanko

module CourseSurveys

  class ScheduleImporter

    class ImportError < StandardError; end
    class CourseMissingError < ImportError
      def initialize(x)
        if x.is_a? Hash
          x = "#{x['Course'][:name]} #{[x[:prefix],x[:course_number],x[:suffix]].join}"
        end

        super(x)
      end
    end
    class InstructorMissingError < ImportError; end

    module Regex
      CourseName = /(.*) [PS] ([^\s]+) (.*)/  # COMPUTER SCIENCE C61C S 001 LEC
      Location   = /(.*),\s+(.*)/             # Tu 4-6P, 310 SODA
      Enrollment = /\s*([^:]*):(\d+)/         # Limit:20 Enrolled:9 Waitlist:2 Avail Seats:11
    end

    DefaultOptions = {
      :ignore => [:lab, :dis, :rec, :ind]
    }

    # Department model
    attr_accessor :department

    def initialize(url, options={}, *args)
      require 'nokogiri'
      require 'open-uri'

      @url     = url

      @klasses = []
      @current_klass = nil
      @semester = nil

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
          end
        end

        @current_klass[item] = value
      end
    end

    # Parses the selected schedule into an internal data structure.
    def run
      orig_url = @url

      while @url
        puts @url.inspect
        doc = Nokogiri::HTML( open(@url) )

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

              begin
                item = item.text[0..-4]   # WTH IS THAT CHARACTER AT THE END
              rescue => fuckaduck         # WHY DOESNT THE OTHER RESCUE WORK FOR THIS LINE
                puts "fuckaduck"
                #exit
              end

              # process value
              value = value.text.strip
              value = nil if value.empty?

              if value =~ /next results/
                href = tr.at_xpath('.//a').attribute('href').value.to_s
                @url = tidy_url(href)
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
      Coursesurvey.transaction do
        @klasses.each_with_index do |klass, i|
          begin
            #puts "#{i.to_s.rjust 4}. #{klass.inspect}" if @debug

            # Find department, course
            dept, prefix, num, suffix = klass['Course'][:name].scan( /(.*) ([A-Z]?)(\d+)([A-Z]?)/ ).first
            num = {:prefix => prefix, :course_number => num.to_i, :suffix => suffix}
            dept   = Department.find_by_name(dept.titleize)
            course = dept.courses.where(num).first

            unless course
              raise CourseMissingError.new(klass)
              #raise ImportError.new("Missing course #{dept.abbr} #{[num[:prefix],num[:course_number],num[:suffix]].join}")
            end

            # Klass
            k = Klass.find_or_initialize_by_course_id_and_semester_and_section(course.id, @semester, klass['Course'][:section])
            if k.new_record?
              k.location = klass['Location']
              k.time     = klass['Time']
              k.notes    = klass['Note']
              k.num_students = klass['Enrollment'][:enrolled]
              k.save || raise(ImportError.new(k.errors.inspect))
              # TODO instructors
            end

            puts "Using #{k.inspect}" if @debug

            # Coursesurvey
            c = Coursesurvey.new
            c.max_surveyors = 2
            c.klass = k
            c.status = 0
            c.save || raise(ImportError.new(c.errors.inspect))

            puts c.inspect if @debug
          rescue => e
            puts "Failed to process #{klass.inspect}:\n  #{e.inspect}"
            puts "klass: #{k.inspect}", "course: #{k.course.inspect}", "coursesurvey: #{c.inspect}"
            raise
          end # b-r-e
        end # each
      end # transaction
    end

  end # ScheduleImporter

end # CourseSurveys
