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

  has_many :instructorships
  has_many :klasses,     :through => :instructorships, :conditions => {:instructorships => {:ta => false}}
  has_many :tad_klasses, :through => :instructorships, :conditions => {:instructorships => {:ta => true }}, :source => :klass
  has_many :survey_answers, :through => :instructorships

  #validates_presence_of :first_name
  validates_presence_of :last_name

  validates_uniqueness_of :first_name, :scope => :last_name

  # sunspot
  searchable do
    text :full_name
  end
  # end sunspot

  # Eat another instructor
  # This destroys the other instructor, moving all of his/her
  # associations to this one.
  # @return [boolean] true if operation was successful
  #
  # THIS SHOULD BE WRAPPED IN A TRANSACTION
  # ITS DESTRUCTIVE
  #
  def eat(victims)
    b = true
    victims = [*victims]
    raise "Nil victim" unless victims.all?

    things = victims.collect(&:instructorships).flatten
    puts "iships = #{things.inspect}\n\n"

    [*victims].each do |victim|
        puts "about to eat #{victim.inspect}\n"
        raise "Failed to destroy" unless victim.destroy
    end

    raise "Can't save self" if self.new_record? && !self.save

    things.each do |thing|
      puts "  updating #{thing.inspect}"
      raise "Failed update" unless thing.update_attribute(:instructor_id, self.id)
      thing.reload
      raise "Failed check" unless thing.instructor_id == self.id
    end

    puts "eat #{victims.inspect} returning okay"
    true
  end

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

  # Reverse order without spaces
  def full_name_r_strip
    [last_name, first_name].join ','
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

  private

  def reassociate(relation)
    relation.collect do |x|
      x.update_attribute(:instructor_id, self.id)
      x.reload
      puts "  checkin #{x.inspect}"
      raise unless x.instructor == self
      true
    end .all?
  end
 

end
