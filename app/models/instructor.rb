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

  def coursesZZZZ(options={})
    courses = Course.find(:all, {
                 :select => "DISTINCT courses.*",
                 #:group =>  "courses.id, courses.course_number, klasses.semester",
                 #:order => "klasses.semester DESC",
                 :conditions => "klasses_tas.instructor_id = #{id}",
                 :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN klasses_tas ON klasses_tas.klass_id = klasses.id"
                 }.merge(options)
                ) + 
                Course.find(:all, {
                 :select => "DISTINCT courses.*",
                 #:group =>  "courses.id",
                 :conditions => "instructors_klasses.instructor_id = #{id}",
                 :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN instructors_klasses ON instructors_klasses.klass_id = klasses.id"
                 }.merge(options)
                )
    courses.sort{|a,b| a.course_abbr <=> b.course_abbr}
  end

  def average_rating
    SurveyAnswer.average(:mean, :conditions => {:survey_question_id=>[SurveyQuestion.find_by_keyword(:prof_eff).id, SurveyQuestion.find_by_keyword(:ta_eff).id], :instructor_id=>id})
  end

  def full_name
    [first_name,last_name].join ' '
  end

  # Reverse order
  def full_name_r
    [last_name, first_name].join ', '
  end
  
  def ta?
    if title.blank? then
      logger.warn "Blank title for instructor ##{id} #{full_name}"
    end
    !!(title =~ /TA|Teaching Assistant/)
  end
  def instructor?
    not ta?
  end

  def Instructor.find_by_name(first_name, last_name)
    Instructor.find(:first, :conditions => { :first_name => first_name, :last_name => last_name} )
  end

end
