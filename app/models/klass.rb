class Klass < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   course_id    : integer 
  #   semester     : string 
  #   location     : string 
  #   time         : string 
  #   section      : integer 
  #   notes        : string 
  #   num_students : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :course
  has_many :coursesurveys
  has_many :survey_answers
  has_and_belongs_to_many :instructors
  # tas = TAs
  has_and_belongs_to_many :tas, { :class_name => "Instructor", :join_table => "klasses_tas" }
  has_many :exams
  
  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }

  def to_s
    "#{course.course_abbr} #{proper_semester}"
  end

  def all_sections
    # This is slow, but whatever.. there shouldn't be too many klasses for a given semester
    Klass.find(:all, :conditions => {:course_id => self.course.id, :semester => self.semester})
  end
  def has_other_sections?
    not all_sections.empty?
  end

  def proper_semester
    section_string = all_sections.length > 1 ? " Section #{section}" : ""
    "#{SEMESTER_MAP[semester[-1..-1].to_i]} #{semester[0..3]}#{section_string}"
  end

  def url_semester
    "#{semester[0..3]}_#{SEMESTER_MAP[semester[-1..-1].to_i]}"
  end

  def instructor_type(instructor)
    instructor_ids.include?(instructor.id) ? "Instructor" : "TA"
  end
end
