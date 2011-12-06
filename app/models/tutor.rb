class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   languages  : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   adjacency  : integer 
  # =======================

  belongs_to :person

  has_many :course_preferences, :dependent => :destroy
  has_many :courses, :through => :course_preferences, :uniq => true
  has_and_belongs_to_many :slots
  has_many :availabilities

  validates :person, :presence => true

  # A current tutor has an {Election} for the current semester,
  # as given by {Property.current_semester}.
  # Also sorts by [{Person.first_name first_name}, {Person.last_name last_name}].
  scope :current, lambda { joins([:person, {:person => :elections}]).where(:elections => {:semester => Property.current_semester, :elected => true}).order(:first_name,:last_name) }
  
  def to_s
    return person.fullname
  end

  def get_availability_by_day_hour(weekday,hour)
    #weekdays = {"Monday" => 5, "Tuesday" => 6, "Wednesday" => 7, "Thursday" => 1, "Friday" => 2, "Saturday" => 3, "Sunday" => 4}
    #t = Time.gm(1970,1,weekdays[weekday],hour,0,0).in_time_zone
    t = Availability.time_for_weekday_and_hour(weekday,hour)
    return Availability.find(:first, :conditions => { :time => t, :tutor_id => self.id })
  end
end
