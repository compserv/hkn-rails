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
    Cory   = 0
    Soda   = 1
    ProDevCory = 2
    Valid = [Cory, Soda, ProDevCory]
    Both  = Valid         # just an alias
  end

  module Wday
    Monday = 1
    Friday = 5
    Valid  = (Monday..Friday)
  end

  module Hour
    Valid = (11 .. 17)
  end

  ROOMS = { cory: Room::Cory, soda: Room::Soda, prodevcory: Room::ProDevCory}

  has_and_belongs_to_many :tutors, before_add: :check_tutor

  validate :valid_room
  validate :valid_hour
  validates :room, presence: true, inclusion: { in: Room::Valid }
  validates :wday, presence: true, inclusion: { in: Wday::Valid }
  validates :hour, presence: true, inclusion: { in: Hour::Valid }, uniqueness: { scope: [:wday, :room] }

  HOUR_RANGE_ERROR = "hour must be within tutoring hours"
  ROOM_ERROR = "room needs to be 0 (Cory), 1 (Soda), 2 (Online), or 3 (ProDev at Cory)"

  def to_s
    "Slot #{room_name} #{day_name} #{hour}"
  end

  def inspect
    "<#Slot #{room_name} #{day_name} #{hour}>"
  end

  def display
    start, stop = [hour, hour + 1].collect { |h| h > 12 ? h - 12 : h }
    "#{day_name}, #{start}-#{stop} @ #{room_name}"
  end

  def room_name
    if room == Room::Cory then
      "Cory"
    elsif room == Room::Soda then
      "Soda"
    elsif room == Room::ProDevCory then
      "ProDev OH (Cory 290)"
    end
  end

  def day_name
    day_to_wday = { "Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5 }
    day_to_wday.key(wday)
  end

  def valid_room
    if !room.blank?
      errors[:room] << ROOM_ERROR unless (room == 0 or room == 1 or room == 2)
    end
  end

  def valid_hour
    unless (Property.tutoring_start..Property.tutoring_end).include? hour
      errors[:hour] << HOUR_RANGE_ERROR
    end
  end

  def check_tutor(tutor)
    if (room == Room::ProDevCory)
      # If it's a ProDev slot, ok to duplicate ... just not Soda and Cory tho
      return
    end
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
