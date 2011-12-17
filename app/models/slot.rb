class Slot < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   room       : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   hour       : integer 
  #   wday       : integer 
  # =======================

  # This is a tutoring office hours slot

  #has_and_belongs_to_many :tutors, :after_add => :check_tutor
  has_and_belongs_to_many :tutors
  has_many :slot_changes

  validate :valid_room
  validates :room, :presence => true
  #validates :time, :presence => true

  #@day_to_wday = {"Monday"=>1, "Tuesday"=>2, "Wednesday"=>3, "Thursday"=>4, "Friday"=>5}
  #@shortday_to_wday = {"Mon"=>1, "Tue"=>2, "Wed"=>3, "Thu"=>4, "Fri"=>5}
  #@room_to_int = {"Cory"=>0, "Soda"=>1}
  ROOMS = {cory: 0, soda: 1}
  #class << self
  #  attr_reader :day_to_wday, :room_to_int, :shortday_to_wday
  #  def extract_day_time(str)
  #    begin
  #      wday = Slot.shortday_to_wday[str[0..2]]
  #      hour = Integer(str[3..4])
  #      return wday, hour
  #    rescue
  #      return nil
  #    end
  #  end
  #  def get_from_string(str)
  #    daytime = extract_day_time(str)
  #    time = get_time(daytime[0], daytime[1])
  #    room = room_to_int[str[5..8]] || {"C"=>0, "S"=>1}[str[5..5]]
  #    return find_by_time_and_room(time, room) || (raise "Nil slot for time #{time.to_s} and room #{room}")
  #  end
  #  def get_time(wday, hour)
# #     base = Time.at(0).utc
# #     thetime = hour.hours + ((wday - base.wday) % 7).days
# #     Time.at(thetime.value)
  #    
  #    #Time.local(0,1,wday+1,hour,0)
  #    Availability.time_for_weekday_and_hour(wday,hour)
  #  end

  #  def get_time_str(wday, hour)
  #   get_time.strftime('%a%H')
  #  end
  #  def find_by_wday(wday)
  #    all.select {|slot| slot.wday == wday}
  #  end
  #  def find_by_wday_and_room(wday, room)
  #    find_by_wday(wday).select {|slot| slot.room == room}
  #  end
  #  def find_by_wday_hour_and_room(wday, hour, room)
  #    all.select {|slot| slot.wday == wday && slot.hour == hour && slot.room == room}
  #  end
  #end

  #def to_s
  #  #time.strftime('%a%H') + get_room()[0..0]
  #end

  def inspect
    "<#Slot #{room_name} #{day_name} #{hour}>"
  end

  def room_name
    if room == 0 then
      "Cory"
    elsif room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end

  def day_name
    day_to_wday = {"Monday"=>1, "Tuesday"=>2, "Wednesday"=>3, "Thursday"=>4, "Friday"=>5}
    day_to_wday.key(wday)
  end

  def valid_room
    if !room.blank?
      errors[:room] << "room needs to be 0 (Cory) or 1 (Soda)" unless (room == 0 or room == 1)
    end
  end

  # TODO: Resolve this
  #def check_tutor(tutor)
  #  otherslot = Slot.find_by_time_and_room(time, 1-room)
  #  other_tutors = otherslot.tutors if otherslot
  #  other_tutors ||= []
  #  for other_tutor in other_tutors
  #    if tutor == other_tutor
  #      tutors.delete(tutor)
  #      break
  #    end
  #  end
  #end

  def availabilities
    return Availability.where(:hour => hour, :wday => wday)
  end
  #def get_all_tutors
  #  return Availability.where(:time=>time).collect(&:tutor)
  #end
  #def get_available_tutors
  #  return Availability.where(:time=>time, :preference_level=>2).collect(&:tutor)
  #end
  #def get_preferred_tutors
  #  return Availability.where(:time=>time, :preference_level=>1).collect(&:tutor)
  #end
end
