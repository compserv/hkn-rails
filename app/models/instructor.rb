class Instructor < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   last_name    : string 
  #   picture      : string 
  #   title        : string 
  #   phone_number : string 
  #   email        : string 
  #   home_page    : string 
  #   interests    : text 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  #   private      : boolean 
  #   office       : string 
  #   first_name   : string 
  # =======================

  has_many :coursesurveys
  has_many :instructorships
  has_many :klasses,     :through => :instructorships, :conditions => {:instructorships => {:ta => false}}
  has_many :tad_klasses, :through => :instructorships, :conditions => {:instructorships => {:ta => true }}, :source => :klass
  has_many :survey_answers, :through => :instructorships

  #validates_presence_of :first_name
  validates_presence_of :last_name

  # sunspot
  searchable do
    text :full_name
  end
  # end sunspot

  def instructed_courses
    Course.where(:id => klasses.collect(&:course_id).uniq).ordered
  end
  def tad_courses
    Course.where(:id => tad_klasses.collect(&:course_id).uniq).ordered
  end

  def average_rating
    q = SurveyQuestion.find_by_keyword(self.student_instructor? || self.instructor? ? :prof_eff : :ta_eff)
    survey_answers.where(:survey_question_id =>q.id).average(:mean)
  end

  def full_name
    [first_name,last_name].join ' '
  end

  # Reverse order
  def full_name_r
    [last_name, first_name].join ', '
  end
  
  def ta?
    not instructor? and not student_instructor?
#    if title.blank? then
#      logger.warn "Blank title for instructor ##{id} #{full_name}"
#    end
#    !!(title =~ /TA|Teaching Assistant/)
  end
  def instructor?
    return false if title.blank?
    return false if self.student_instructor?
    title =~ /Professor|Lecturer|Instructor/i
  end
  def student_instructor?
    title =~ /Student Instructor/i
  end

  def Instructor.find_by_name(first_name, last_name)
    Instructor.find(:first, :conditions => { :first_name => first_name, :last_name => last_name} )
  end

end
