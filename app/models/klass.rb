class Klass < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   course_id    : integer 
  #   semester     : string 
  #   location     : string 
  #   time         : string 
  #   section      : integer 
  #   notes        : text 
  #   num_students : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :course
  has_one :coursesurvey, :dependent => :destroy
  has_many :survey_answers, :dependent => :destroy
  has_and_belongs_to_many :instructors
  # tas = TAs
  has_and_belongs_to_many :tas, { :class_name => "Instructor", :join_table => "klasses_tas" }
  has_many :exams, :dependent => :destroy

  scope :current_semester, lambda{ joins(:course).where('klasses.semester' => Property.get_or_create.semester).order('courses.department_id, courses.prefix, courses.course_number, courses.suffix ASC, section') }
  
  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }
  ABBR_SEMESTERS = { 'sp' => 1, 'su' => 2, 'fa' => 3 }

  def self.semester_code_from_s(s)
    # Converts string like "FALL 2010" to "20103"
    sem, year = s.split
    sem = SEMESTER_MAP.invert[sem.capitalize]
    "#{year}#{sem}"
  end

  def to_s
    "#{course.course_abbr} #{proper_semester}"
  end

  def all_sections
    # This is slow, but whatever.. there shouldn't be too many klasses for a given semester
    Klass.find(:all, :conditions => {:course_id => course_id, :semester => semester})
  end
  def has_other_sections?
    not Klass.find(:first, :conditions => ['course_id = ? and semester = ? and id != ?', course_id, semester, id]).nil?
  end

  def proper_semester(options={})
    # e.g. Fall 2010 Section 2
    # options
    #  - sections: set true to show 'Section n' when multiple sections are present for the same semester
    #
    section_string = (all_sections.length > 1 ? " Section #{section}" : "") if options[:sections]
    "#{SEMESTER_MAP[semester[-1..-1].to_i]} #{semester[0..3]}#{section_string}"
  end

  def url_semester
    "#{semester[0..3]}_#{SEMESTER_MAP[semester[-1..-1].to_i]}"
  end

  def instructor_type(instructor)
    instructor_ids.include?(instructor.id) ? "Instructor" : "TA"
  end

  # e.g. sp05
  def Klass.find_by_course_and_nice_semester(course, nice_semester)
    # kind of a hacky way to convert decades, but should be fine if we
    # replace this format/website by 2051
    decade = nice_semester[2..3].to_i
    year = (decade > 50 ? 1900 : 2000) + decade
    semester = "#{year}#{ABBR_SEMESTERS[nice_semester[0..1]]}"
    Klass.find_by_course_id_and_semester(course.id, semester)
  end
end
