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
  # =======================

  has_and_belongs_to_many :tutors
  validates :department, :presence => true
  validates :course_number, :presence => true

  def get_dept_name()
    if department == 0 then
      "EE"
    elsif department == 1 then
      "CS"
    else
      "Unknown"
    end
  end
end
