class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   languages  : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person

  has_many :course_preferences, :dependent => :destroy
  has_many :courses, :through => :course_preferences, :uniq => true
  has_and_belongs_to_many :slots
  has_many :availabilities

  validates :person, :presence => true
  
  def to_s
    return person.fullname
  end

  def get_availability_by_day_hour(weekday,hour)
    weekdays = {"Monday" => 5, "Tuesday" => 6, "Wednesday" => 7, "Thursday" => 1, "Friday" => 2, "Saturday" => 3, "Sunday" => 4}
    t = Time.gm(1970,1,weekdays[weekday],hour,0,0).in_time_zone
    a = Availability.find(:all, :conditions => { :time => t, :tutor_id => self.id })
    if a.empty?
      return nil
    else
      return a[0]
    end
  end
end
