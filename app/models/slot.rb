class Slot < ActiveRecord::Base

  # ==== List of columns ====
  #   time    : Time
  #   tutors  : Tutor[]
  #   room    : Int
  #   changes : slot_change[]
  # =========================

  # HKN tutoring is from 11am to 5pm, Mon-Fri
  Max_Hour = 17 
  Min_Hour = 11 
  Max_Day = 5
  Min_Day = 1

  has_many :tutors
  has_many :slot_changes

  validate :valid_time_range

  def get_room()
    if room == 0 then
      "Cory"
    elsif room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end

  def valid_time_range
    if !time.blank
      errors[:base] << "Time must be within 11 to 5, Monday to Friday" unless ((time.hour <= Max_Hour and time.hour >= Min_Hour) and (time.wday <= Max_Day and time.wday >= Min_Day))
    end
  end
end
