class Slot < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   time       : datetime 
  #   room       : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_and_belongs_to_many :tutors
  has_and_belongs_to_many :availabilities
  has_many :slot_changes

  validate :valid_room
  validates :room, :presence => true
  validates :time, :presence => true

  def to_s
    time.strftime('%a%H')
  end

  def Slot.get_time(wday, hour)
    base = Time.at(0)
    thetime = hour.hours + ((wday - base.wday) % 7).days
    Time.at(thetime.value)
  end

  def get_room()
    if room == 0 then
      "Cory"
    elsif room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end

  def valid_room
    if !room.blank?
      errors[:room] << "room needs to be 0 (Cory) or 1 (Soda)" unless (room == 0 or room == 1)
    end
  end
end
