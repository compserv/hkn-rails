class Event < ActiveRecord::Base

  # === List of columns ===
  #   id                  : integer 
  #   name                : string 
  #   slug                : string 
  #   location            : string 
  #   description         : text 
  #   start_time          : datetime 
  #   end_time            : datetime 
  #   created_at          : datetime 
  #   updated_at          : datetime 
  #   event_type_id       : integer 
  #   need_transportation : boolean 
  # =======================

  has_many :blocks, :dependent => :destroy
  has_many :rsvps, :dependent => :destroy
  belongs_to :event_type
  validates :name, :presence => true
  validates :location, :presence => true
  validates :description, :presence => true
  validates :event_type, :presence => true
  validate :valid_time_range

  scope :past,     joins(:event_type).order(:start_time).where(['start_time < ?', Time.now])
  scope :upcoming, joins(:event_type).order(:start_time).where(['start_time > ?', Time.now])
  scope :candidate,joins(:event_type).order(:start_time).where(['?.includes?(event_type.name)', "Big Fun", "Fun"])
  scope :all,      joins(:event_type).order(:start_time)

  # Note on slugs: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html 

  def valid_time_range
    if !start_time.blank? and !end_time.blank?
      errors[:end_time] << "must be after start time" unless start_time < end_time
    end
  end

  def short_start_time
    ampm = (start_time.hour >= 12) ? "p" : "a"
    min = (start_time.min > 0) ? start_time.strftime('%M') : ""
    hour = start_time.hour
    if hour > 12
      hour -= 12
    elsif hour == 0
      hour = 12
    end
    "#{hour}#{min}#{ampm}"
  end

  def nice_time_range
    if start_time.to_date == end_time.to_date 
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%I:%M%p')}"
    else 
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%a %m/%d %I:%M%p')}"
    end 
  end
end
