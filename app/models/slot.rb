class Slot < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   time       : datetime 
  #   room       : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_and_belongs_to_many :tutors
  has_many :slot_changes

  validate :valid_room
  validates :room, :presence => true
  validates :time, :presence => true

  @day_to_wday = {"Monday"=>1, "Tuesday"=>2, "Wednesday"=>3, "Thursday"=>4, "Friday"=>5}
  @shortday_to_wday = {"Mon"=>1, "Tue"=>2, "Wed"=>3, "Thu"=>4, "Fri"=>5}
  @room_to_int = {"Cory"=>0, "Soda"=>1}
  class << self
    attr_reader :day_to_wday, :room_to_int, :shortday_to_wday
    def extract_day_time(str)
      begin
        wday = Slot.shortday_to_wday[str[0..2]]
        hour = Integer(str[3..4])
        return wday, hour
      rescue
        return nil
      end
    end

    def get_time(wday, hour)
      base = Time.at(0)
      thetime = hour.hours + ((wday - base.wday) % 7).days
      Time.at(thetime.value)
    end

    def get_time_str(wday, hour)
      base = Time.at(0)
      thetime = hour.hours + ((wday - base.wday) % 7).days
      Time.at(thetime.value).strftime('%a%H')
    end
  end

  def to_s
    time.strftime('%a%H')
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

  def hour
    time.hour
  end

  def wday
    time.wday
  end

  def valid_room
    if !room.blank?
      errors[:room] << "room needs to be 0 (Cory) or 1 (Soda)" unless (room == 0 or room == 1)
    end
  end
  
  def availabilities
    return Availability.where(:time=>time)
  end
  def get_all_tutors
    return Availability.where(:time=>time).map{|x| x.tutor}
  end
  def get_available_tutors
    return Availability.where(:time=>time, :preference_level=>1).map{|x| x.tutor}
  end
  def get_preferred_tutors
    return Availability.where(:time=>time, :preference_level=>2).map{|x| x.tutor}
  end
end
