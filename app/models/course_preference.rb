class CoursePreference < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   course_id  : integer 
  #   tutor_id   : integer 
  #   level      : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  #Level 0 = current, Level 1 = completed, Level 2 = preferred

  belongs_to :course
  belongs_to :tutor

  validates :course, :presence => true
  validates :tutor, :presence => true
  validates :level, :presence => true
  validates_numericality_of :level, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :level, :in => 0..2, :message => "invalid value." 
  validates_uniqueness_of :course_id, :scope => :tutor_id

  #For scheduler class view
  def CoursePreference.all_courses(tutors)
    ret = Hash.new()

    Course.joins(:course_preferences).where(:course_preferences => {:tutor_id=>tutors.collect(&:id)}).ordered.each do |c|
      ret[c.dept_abbr] ||= []
      ret[c.dept_abbr] << c.full_course_number
    end

    return ret
  end

end
