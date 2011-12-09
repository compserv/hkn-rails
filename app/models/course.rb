class Course < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   suffix        : string 
  #   prefix        : string 
  #   name          : string 
  #   description   : text 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  #   units         : integer 
  #   prereqs       : text 
  #   department_id : integer 
  #   course_number : integer 
  # =======================

  belongs_to :department
  has_many :course_preferences, :dependent => :destroy
  has_many :tutors, :through => :course_preferences, :uniq => true
  has_many :klasses, :order => "semester DESC, section DESC", :dependent => :destroy
  has_many :coursesurveys, :through => :klasses
  #has_many :instructors, :source => :klasses, :conditions => ['klasses.course_id = id'], :class_name => 'Klass'
  has_many :instructorships, :through => :klasses
                  
  has_many :exams
  validates :department_id, :presence => true
  validates :course_number, :presence => true
  validates_uniqueness_of :course_number, :scope => [:department_id,:prefix,:suffix]

  #scope :all, order("prefix, courses.course_number, suffix")
  scope :ordered, order("courses.course_number, prefix, suffix")
  scope :ordered_desc, order("(prefix, courses.course_number, suffix) DESC")

  attr_accessible :name, :description, :units, :prereqs, :department_id

  module Regex
    PrefixNumSuffix = /^([A-Z]*)(\d+)([A-Z]*)$/
  end

  # Sunspot
  searchable do
    text :name, :stored => true, :boost => 2.0
    text :description, :stored => true
    integer :course_number, :stored => true
    text :course_string, :boost => 2.0 do |c|
      [c.prefix, c.course_number.to_s, c.suffix].join
    end
    string :course_abbr
    text :course_abbr
    text :dept_abbrs do |c|
      [c.department.name, c.department.abbr, c.department.nice_abbrs].join(' ')
    end
    integer :department_id, :references => Department
    boolean :invalid, :using => :invalid?
  end
  # end sunspot

  # A few notes about course numbers
  # prefix refers to letters that appear before numbers, e.g. C for cross-listed, H for honors
  # course_number refers to just the numbers, e.g. the 61 in 61A
  # suffix refers to all letters that appear after the numbers, e.g. the A in 61A, the M in 145M, the AC in E130AC
  # This is DIFFERENT from the old Django site's definitions

  def instructors(conds={:ta=>false})
    Instructor.find self.klasses.collect(&:instructor_ids).flatten.uniq
  end

  def tas
    instructors(:ta=>true)
  end

  def classification
  # is this an undergrad or grad class?
      case course_number
      when 0..199 then :undergrad
      else         :grad
      end
  end

  def average_rating
    # BE CAREFUL, THIS IS KIND OF EXPENSIVE
    SurveyAnswer.
      where( :survey_question_id => SurveyQuestion.find_by_keyword(:prof_eff),
             :id => self.instructorships.collect(&:survey_answer_ids) ).
      average(:mean)
  end

  def latest_klass
  # Return the latest klass for which there is survey data
      k = klasses.ordered
      k.drop_while {|k| not k.survey_answers.exists?}
      k.first
  end

  def invalid?
    # Some courses are invalid, and shouldn't be listed.
    !!(name =~ /INVALID/)
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

  # @return [String] [dept.slug, full_course_number] for use in a course url. Explode it.
  def slug
    [department.slug, full_course_number]
  end

  def self.split_course_number(s, options={})
    # Splits a course number string "C149" => "C", 149, nil
    cn = {}
    cn[:prefix], cn[:course_number], cn[:suffix] = s.upcase.scan(Regex::PrefixNumSuffix).first
    cn[:course_number] = cn[:course_number].to_i

    return [cn[:prefix], cn[:course_number], cn[:suffix]] if options[:hash] == false

    return cn
  end

  # E.g. ("EE", "C149")
  def Course.find_by_short_name(dept_abbr, full_course_number, section=nil)
    (prefix, course_number, suffix) = full_course_number.scan(Regex::PrefixNumSuffix).first
    department = Department.find_by_nice_abbr(dept_abbr)
    #raise "Course abbreviation not well formatted: #{dept_abbr} #{full_course_number}" if course_number.blank? or department.nil?
    return nil if course_number.blank? or department.nil?

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
      Course.where(:department_id => @department.id).ordered.reject {|course| course.exams.empty?}
    end
  end
end
