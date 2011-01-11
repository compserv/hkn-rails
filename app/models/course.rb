class Course < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   course_number : string 
  #   suffix        : string 
  #   prefix        : string 
  #   name          : string 
  #   description   : text 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  #   units         : integer 
  #   prereqs       : text 
  #   department_id : integer 
  # =======================

  belongs_to :department
  has_many :course_preferences
  has_many :tutors, :through => :course_preferences
  has_many :klasses, :order => "semester DESC, section DESC"
  has_many :coursesurveys, :through => :klasses
  has_many :instructors, :source => :klasses, :conditions => ['klasses.course_id = id'], :class_name => 'Klass'
  has_many :exams
  validates :department_id, :presence => true
  validates :course_number, :presence => true
  validates :name,          :presence => true

  scope :ordered, order("prefix, CAST(courses.course_number AS integer), suffix")
  scope :ordered_desc, order("(prefix, CAST(courses.course_number AS integer), suffix) DESC")
  
  def invalid?
    # Some courses are invalid, and shouldn't be listed.
    name =~ /INVALID/
  end

  def dept_abbr
    department.nice_abbrs.first
  end

  def dept_name
    department.name
  end

  def course_name
    # e.g. Electrical Engineering 20N
    "#{dept_name} #{full_course_number}"
  end

  def course_abbr
    # e.g. EE20N
    "#{dept_abbr}#{full_course_number}"
  end

  def to_s
    course_abbr
  end

  def full_course_number
    "#{prefix}#{course_number}#{suffix}"
  end

  # E.g. ("EE", "C149")
  def Course.find_by_short_name(dept_abbr, full_course_number, section=nil)
    (prefix, course_number, suffix) = full_course_number.scan(/^([a-zA-Z]*)([0-9]*)([a-zA-Z]*)$/).first
    department = Department.find_by_nice_abbr(dept_abbr)
    raise "Course abbreviation not well formatted: #{dept_abbr} #{full_course_number}" if course_number.blank? or department.nil?

    Course.find( :first, :conditions => { :department_id => department.id, :course_number => course_number, :suffix => suffix, :prefix => prefix } )
  end

  def Course.find_all_by_department_abbr(dept_abbr)
    department = Department.find_by_nice_abbr(dept_abbr)
    Course.find_all_by_department_id(department.id)
  end

  def Course.find_all_with_exams_by_department_abbr(dept_abbr)
    @department = Department.find_by_nice_abbr(dept_abbr)
    if !@department.nil?
      # TODO fix query to be more efficient
      Course.where(:department_id => @department.id).reject {|course| course.exams.empty?}
    end
  end
end
