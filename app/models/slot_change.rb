class SlotChange < ActiveRecord::Base
 
  # HKN tutoring is from 11am to 5pm, Mon-Fri
  Max_Hour = 17
  Min_Hour = 11
  Max_Day = 5
  Min_Day = 1

  has_one :tutor

  validate :valid_date

  def valid_date
    if !date.blank
      errors[:base] << "Time must be within 11 to 5, Monday to Friday" unless ((time.hour <= Max_Hour and time.hour >= Min_Hour) and (time.wday <= Max_Day and time.wday >= Min_Day))
    end
  end

  def get_type()
    if type == 0 then
      "Add"
    elsif type == 1 then
      "Subtract"
    else
      "Unknown"
    end
  end
end
