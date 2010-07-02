class Availability < ActiveRecord::Base

  # === List of columns ===
  #   id             : integer 
  #   tutor_id       : integer 
  #   preferred_room : integer 
  #   created_at     : datetime 
  #   updated_at     : datetime 
  # =======================

  # HKN tutoring is from 11am to 5pm, Monday to Friday
  Max_Hour = 17
  Min_Hour = 11
  Max_Day = 5
  Min_Day = 1

  has_many :Time
  has_one :tutor

  validate :valid_times

  def get_preferred_room()
    if preferred_room == 0 then
      "Cory"
    elsif preferred_room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end 

  def valid_times
    if !times.blank
      times.length.times do |i|
        errors[:base] << "Time must be within 11 to 5, Monday to Friday" unless ((time.hour <= Max_Hour and time.hour >= Min_Hour) and (time.wday <= Max_Day and time.wday >= Min_Day))
      end    
    end
  end
end
