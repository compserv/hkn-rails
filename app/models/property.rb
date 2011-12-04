class Property < ActiveRecord::Base

  # === List of columns ===
  #   id                   : integer 
  #   semester             : string 
  #   created_at           : datetime 
  #   updated_at           : datetime 
  #   tutoring_enabled     : boolean 
  #   tutoring_message     : text 
  #   tutoring_start       : integer 
  #   tutoring_end         : integer 
  #   coursesurveys_active : boolean 
  # =======================

  Semester = /^\d{4}[0-5]$/	#A regex which validates the semester
  validates_format_of :semester, :with => Semester, :message => "Not a valid semester."
  validate :there_is_only_one, :on => :create
  validates_numericality_of :tutoring_start, :greater_than_or_equal_to => 11
  validates_numericality_of :tutoring_end, :greater_than => :tutoring_start, :less_than_or_equal_to => 16

  MONTH_SEMESTER_MAP = { 1..5 => 1, 6..7 => 2, 8..12 => 3 }
  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }

  module Regex
    SemesterString = /([A-Za-z]+)\s+(\d+)/
  end

  class << self
    def get_or_create
      prop = Property.first
      if prop.nil? then prop = Property.create end
      return prop
    end

    #The below code enables some magic allowing you to do things like
    #Property.semester to get the current semester, or Property.semester= to
    #set the current semester. However, if you use this, you can't also use an
    #instance of Property.first because the fields aren't kept in sync.
    # def respond_to?(method_id, include_private = false)
      # if super: return super end
      # prop = get_or_create
      # if prop.attribute_names.include? method_id.to_s then return true end
      # return false
    # end

    # def method_missing(method_id, *arguments, &block)
      # prop = get_or_create
      # if prop.attribute_names.include?(method_id.to_s)
        # return prop.send(method_id.to_s)
      # elsif (method_id.to_s =~ /(\w*)=/ and prop.attribute_names.include? $1)
        # set_property($1, arguments.first)
      # else
        # super
      # end
    # end


    # Makes a coded semester out of year and semester integers.
    # year_and_semester is a hash accepting:
    #   - year      : integer year of desired semester
    #   - semester  : integer semester in [1,2,3]
    #     -OR- month: integer month in [0..11]
    #   Missing arguments default to valus taken from Time.now().
    #
    # With no arguments, calculates the current semester
    def make_semester(year_and_semester={}, options={})
      year_and_semester ||= {}
      year_and_semester = {:year => year_and_semester[0..3], :semester => year_and_semester[4..4]} if year_and_semester.is_a? String
      year     = (year_and_semester.delete(:year)     || Time.now.year).to_i
      semester = (year_and_semester.delete(:semester) || 
                 ( case (year_and_semester.delete(:month) || Time.now.month)
                   when 1..5: 1
                   when 6..7: 2
                   else       3 end     )).to_i
      if options.delete(:hash) then
        {:year => year, :semester => semester}
      else
        "#{year}#{semester}"
      end
    end

    # Parse a semester of the form "Fall 2011" -> "20113"
    # @param semester [String] Like "Fall 2011"
    # @return [String] Semester string "20113"
    def parse_semester(semester)
      season, year = semester.scan(Regex::SemesterString).first
      raise ArgumentError.new("Semester must be of format 'Season yyyy': #{semester.inspect}") unless season and year
      i_season = SEMESTER_MAP.invert[season.titleize]
      raise ArgumentError.new("Unrecognized season #{season}") unless i_season
      return "#{year}#{i_season}"
    end

    def current_semester
      Property.first.semester rescue make_semester
    end

    def offset_semester(year_and_semester={}, options={})
      s = make_semester(year_and_semester, :hash=>true)
      year, sem = s[:year], s[:semester]
      dir  = (options[:dir] == -1) ? -1 : 1
      sem  += dir
      sem  += dir if !options[:summer] && sem == 2   # XXX in the contexts where we use next/prev, it doesn't make sense to return summer
      if dir > 0 && sem > 3 then
        year += 1
        sem = 1
      elsif sem < 1 # dir < 0
        year -= 1
        sem = 3
      end # dir
      "#{year}#{sem}"
     end

    def next_semester(year_and_semester={}, options={})
      offset_semester year_and_semester, {:summer=>false, :dir=>1}.merge(options)
    end

    def prev_semester(year_and_semester={}, options={})
      offset_semester year_and_semester, {:summer=>false, :dir=>-1}.merge(options)
    end

    def current_semester_range
      MONTH_SEMESTER_MAP.each_pair do |months, sem|
        next if Time.now.month > months.last
        this_year = Time.now.year
        Time.local(year, months.first) .. Time.local(year, months.last)
      end
    end

    def set_property(variable, value)
      prop = get_or_create
      prop.send(variable+"=", value)
      prop.save
    end

    def semester_start_time
      prop = get_or_create
      semester = prop.semester.to_s
      semester_year = semester[0..3]

      # 1 = Spring, 2 = Summer, 3 = Fall
      case semester[4..4]
      when "1"
        semester_start_month = 1
        semester_end_month = 5
      when "2"
        semester_start_month = 6
        semester_end_month = 7
      when "3"
        semester_start_month = 8
        semester_end_month = 12
      else
        raise "Error!"
      end

      start_month = ( semester_start_month ).to_i
      start_year = ( semester_year ).to_i

      return Time.local(start_year, start_month).beginning_of_month
    end

    # Pretty semester from "20111"
    def pretty_semester(s=nil)
      s ||= current_semester
      "#{SEMESTER_MAP[s[-1..-1].to_i]} #{s[0..3]}"
    end
    
    def get_property(variable)
      prop = get_or_create
      prop.send(variable)
    end
    protected :set_property, :get_property, :new, :create

    def method_missing(m, *args, &block)
      m = m.to_s
      set = false
      if m[-1..-1] == '='
        m = m[0..-2]
        set = true
      end
      if column_names.include? m
        (set) ? set_property(m, *args) : get_property(m)
      end
    end
  end

  def there_is_only_one
    if Property.count > 0
      errors.add(:base, "There can only be one property entry")
    end
  end

end

