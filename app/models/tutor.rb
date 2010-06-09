class Event < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   slug        : string 
  #   location    : string 
  #   description : text 
  #   start_time  : datetime 
  #   end_time    : datetime 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  Valid_time = /((M|TU|W|TH|F)([1-5]|[11-12])/ # Regex that validates tutoring time 

  validates_presence_of :availabilities
  validates_presence_of :assignments
  validates_presence_of :courses_taken
  validates_presence_of :courses_taking

  validate :valid_time
  validate :valid_preferred_courses  

  def valid_time
    for time in @availabilities
      validates_inclusion_of time, :in => Valid_time, :message => "Invalid time."
    end
   
    for time in @assignments
      validates_inclusion_of time, :in => @availabilities, :message => "Time is not in availability list."
    end
  end
end
