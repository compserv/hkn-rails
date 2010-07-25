class Course < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   department    : integer 
  #   course_number : string 
  #   suffix        : string 
  #   prefix        : string 
  #   name          : string 
  #   description   : text 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  #   units         : integer 
  #   prereqs       : string 
  # =======================

  has_and_belongs_to_many :tutors
  has_many :klasses
  has_many :coursesurveys, :through => :klasses
  has_many :exams
  validates :department, :presence => true
  validates :course_number, :presence => true

  def dept_abbr
    if department == 0 then
      "EE"
    elsif department == 1 then
      "CS"
    else
      "Unknown"
    end
  end

  def dept_name
    if department == 0 then
      "Electrical Engineering"
    elsif department == 1 then
      "Computer Science"
    else
      "Unknown"
    end
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
    (department, course_number, suffix) = course_abbr.scan(/([a-zA-Z]*)([0-9]*)([a-zA-Z]*)/).first
    if department == "EE"
      department = 0
    elsif department == "CS"
      department = 1
    else
      raise "Department name unknown: #{department}"
    end

    if course_number.blank?
      raise "Course abbreviation not well formatted"
    end

    suffix = nil if suffix.blank?

    Course.find( :all, :conditions => { :department => department, :course_number => course_number, :suffix => suffix } )
  end
end
