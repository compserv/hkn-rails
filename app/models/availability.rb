# == Schema Information
#
# Table name: availabilities
#
#  id               :integer          not null, primary key
#  tutor_id         :integer
#  preferred_room   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  preference_level :integer
#  room_strength    :integer          default(0)
#  semester         :string(255)      not null
#  hour             :integer          not null
#  wday             :integer          not null
#

class Availability < ActiveRecord::Base
  # Note: This is different from a Slot because it has no room attribute

  belongs_to :tutor

  PREF = {unavailable: 0, preferred: 1, available: 2}
  VALID_PREF_STRINGS = PREF.keys.map{|x| x.to_s}
  ROOM_ERROR = "room needs to be 0 (Cory) or 1 (Soda)"
  Room = Slot::Room

  validates :tutor, :presence => true
  validates :preference_level, :presence => true, :inclusion => {:in => PREF.values}
  validates :room_strength, :inclusion => {:in => 0..2}
  validates_presence_of :semester
  validates_format_of :semester, :with => Property::Regex::Semester
  validates :hour,
    :presence  => true,
    :inclusion => {:in => Slot::Hour::Valid}
  validates :wday,
    :presence  => true,
    :inclusion => {:in => Slot::Wday::Valid}
  validates :preferred_room,
    :presence  => true,
    :inclusion => {
      :in      => Slot::Room::Valid,
      :message => "should be Cory (#{Slot::Room::Cory}) or Soda (#{Slot::Room::Soda})"
    }
  validates_uniqueness_of :tutor_id, :scope => [:hour, :wday]

  before_validation :touch_semester

  scope :current, lambda { where(:semester => Property.current_semester) }

  class << self

    def slider_value(availability)
      if availability.preferred_room == 0
        return 2 - availability.room_strength
      else
        return 2 + availability.room_strength
      end
    end

    def slider_to_room_strength(value)
      case value
        when 0 then room,strength = 0,2
        when 1 then room,strength = 0,1
        when 2 then room,strength = 0,0
        when 3 then room,strength = 1,1
        when 4 then room,strength = 1,2
      end
      return room, strength
    end
  end

  def get_preferred_room()
    if preferred_room == 0 then
      "Cory"
    elsif preferred_room == 1 then
      "Soda"
    end
  end

  private

  def touch_semester
    self.semester = Property.current_semester unless semester =~ Property::Regex::Semester
  end

end
