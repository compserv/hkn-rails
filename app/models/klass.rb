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
  has_one  :coursesurvey, :dependent => :destroy
  has_many :survey_answers, :through => :instructorships, :dependent => :destroy
  has_many :instructorships
  has_many :instructors, :through => :instructorships, :conditions => {:instructorships => {:ta => false}}
  has_many :tas,         :through => :instructorships, :conditions => {:instructorships => {:ta => true }}, :source => :instructor
  has_many :exams, :dependent => :destroy

  validates_format_of       :semester, :with => /\d{5}/
  validates_numericality_of :section
  validates_presence_of     :course_id
  validates_uniqueness_of   :section, :scope => [:semester, :course_id]

  scope :current_semester, lambda{ joins(:course).where('klasses.semester' => Property.get_or_create.semester).order('courses.department_id, courses.prefix, courses.course_number, courses.suffix ASC, section') }

  scope :ordered, lambda { order("course_number DESC, prefix ASC, suffix ASC, semester DESC") }
  
  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }
  ABBR_SEMESTERS = { 'sp' => 1, 'su' => 2, 'fa' => 3 }

  def self.semester_code_from_s(s)
    # Converts string like "FALL 2010" to "20103"
    year, sem = s.scan(/\d+/).first, s.scan(/[a-zA-Z]+/).first
    sem = SEMESTER_MAP.invert[sem.capitalize]
    return nil unless sem.present? && year.is_int?
    "#{year}#{sem}"
  end

  def to_s
    "#{course.course_abbr} #{proper_semester(:sections=>true)}"
  end

  def all_sections
    course.klasses.where(:semester => self.semester)
  end

  def has_other_sections?
    all_sections.where("id != ?", self.id).exists?
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
