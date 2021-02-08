# == Schema Information
#
# Table name: slots
#
#  id         :integer          not null, primary key
#  room       :integer
#  created_at :datetime
#  updated_at :datetime
#  hour       :integer          not null
#  wday       :integer          not null
#

class Slot < ActiveRecord::Base
  # This is a tutoring office hours slot

  module Room
    Cory  = 0
    Soda  = 1
    Valid = [Cory, Soda]
    Both  = Valid         # just an alias
  end

  module Wday
    Monday = 1
    Friday = 5
    Valid  = (Monday..Friday)
  end

  module Hour
    Valid = (11 .. 16)
  end

  ROOMS = { cory: Room::Cory, soda: Room::Soda }

  has_and_belongs_to_many :tutors, before_add: :check_tutor

  validate :valid_room
  validate :valid_hour
  validates :room, presence: true, inclusion: { in: Room::Valid }
  validates :wday, presence: true, inclusion: { in: Wday::Valid }
  validates :hour, presence: true, inclusion: { in: Hour::Valid }, uniqueness: { scope: [:wday, :room] }

  HOUR_RANGE_ERROR = "hour must be within tutoring hours"
  ROOM_ERROR = "room needs to be 0 (Cory) or 1 (Soda)"

  def to_s
    "Slot #{room_name} #{day_name} #{hour}"
  end

  def inspect
    "<#Slot #{room_name} #{day_name} #{hour}>"
  end

  def display
    applyTempFix = true
    start, stop = [hour, hour + 1].collect { |h| h }
    if applyTempFix
      if start == 11 or start == 12
        start = start + 2
        stop = stop + 2
      elsif start == (1 + 12)
        # Large slot between 3 PM to 7 PM - for No Tutoring
        start = start + 2
        stop = stop + 5
        # This time section shouldn't show for the Spring 2021 tutors anyway...
      else (2 + 12) <= start and start <= (4 + 12)
        start = start + 5
        stop = stop + 5
      end
    end
    start, stop = [start, stop].collect { |h| h > 12 ? h - 12 : h }
    "#{day_name}, #{start}-#{stop} @ Online" # @ #{room_name}"
  end

  def room_name
    if room == Room::Cory then
      "Cory"
    elsif room == Room::Soda then
      "Soda"
    end
  end

  def day_name
    day_to_wday = { "Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5 }
    day_to_wday.key(wday)
  end

  def valid_room
    if !room.blank?
      errors[:room] << ROOM_ERROR unless (room == 0 or room == 1)
    end
  end

  def valid_hour
    unless (Property.tutoring_start..Property.tutoring_end).include? hour
      errors[:hour] << HOUR_RANGE_ERROR
    end
  end

  def check_tutor(tutor)
    flip_room = room == 0 ? 1 : 0
    otherslot = Slot.find_by_wday_and_hour_and_room(wday, hour, flip_room)
    unless otherslot.nil?
      other_tutors = otherslot.tutors
      other_tutors.each do |other_tutor|
        if tutor == other_tutor
          raise "Same tutor in different offices at same time!"
        end
      end
    end
  end

  def availabilities
    return Availability.where(hour: hour, wday: wday)
  end

  def adjacent_to(other_slot)
    other_slot.wday == wday and (other_slot.hour - hour).abs == 1
  end
end
