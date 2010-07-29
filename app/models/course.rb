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
  #   prereqs       : string 
  #   department_id : integer 
  # =======================

  belongs_to :department
  has_and_belongs_to_many :tutors
  has_many :klasses
  has_many :coursesurveys, :through => :klasses
  has_many :exams
  validates :department_id, :presence => true
  validates :course_number, :presence => true

  def dept_abbr
    department.nice_abbrs.first
  end

  def dept_name
    department.name
  end

  def course_name
    # e.g. Electrical Engineering 20N
    "#{dept_name} #{course_number}#{suffix}"
  end

  def course_abbr
    # e.g. EE20N
    "#{dept_abbr}#{course_number}#{suffix}"
  end

  def Course.find_by_course_abbr(course_abbr)
    (dept_abbr, course_number, suffix) = course_abbr.scan(/([a-zA-Z]*)([0-9]*)([a-zA-Z]*)/).first
    department = Department.find_by_nice_abbr(dept_abbr)

    if course_number.blank?
      raise "Course abbreviation not well formatted"
    end

    suffix = nil if suffix.blank?

    Course.find( :all, :conditions => { :department_id => department.id, :course_number => course_number, :suffix => suffix } )
  end
end
