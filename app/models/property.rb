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
