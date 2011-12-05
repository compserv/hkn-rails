class Availability < ActiveRecord::Base

  # === List of columns ===
  #   id               : integer 
  #   tutor_id         : integer 
  #   preferred_room   : integer 
  #   created_at       : datetime 
  #   updated_at       : datetime 
  #   preference_level : integer 
  #   time             : datetime 
  #   room_strength    : integer 
  #   semester         : string 
  # =======================

  
  
  belongs_to :tutor
  
  validate :valid_room
  validates :tutor, :presence => true
  validates :preference_level, :presence => true
  validates_presence_of :semester
  validates_format_of :semester, :with => Property::Regex::Semester
  validates_uniqueness_of :time, :scope => :tutor_id

  before_validation :touch_semester

  scope :current, lambda { where(:semester => Property.current_semester) }
  
  @prefstr_to_int = {"unavailable"=>0, "preferred"=>1, "available"=>2}

  class << self
    attr_reader :prefstr_to_int
    
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

    def time_for_weekday_and_hour(wdaystr, h)
      wday = 1
      case
      when wdaystr.is_a?(String)
        wday = %w(Monday Tuesday Wednesday Thursday Friday).index(wdaystr.capitalize)+1
      when wdaystr.is_a?(Integer)
        wday = wdaystr
      else raise "Availability.time_for_weekday_and_hour: Bad weekday #{wdaystr}"
      end
      Time.local(1,1,wday,h,0)  # jan 2001 => wday == day
    end
  end
  
  def get_preferred_room()
    if preferred_room == 0 then
      "Cory"
    elsif preferred_room == 1 then
      "Soda"
    end 
  end

  def valid_room
    if !preferred_room.blank?
      errors[:preferred_room] << "room needs to be 0 (Cory) or 1 (Soda)" unless (preferred_room == 1 or preferred_room == 0)
    end
  end

  def get_slider_value
    if preferred_room == 0
      return 2 - room_strength
    else
      return 2 + room_strength
    end
  end

  def to_s
    time.strftime('%a%H')
  end

  private

  def touch_semester
    self.semester = Property.current_semester
  end

end
