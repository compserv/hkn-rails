class Event < ActiveRecord::Base

  # === List of columns ===
  #   id                       : integer 
  #   name                     : string 
  #   slug                     : string 
  #   location                 : string 
  #   description              : text 
  #   start_time               : datetime 
  #   end_time                 : datetime 
  #   created_at               : datetime 
  #   updated_at               : datetime 
  #   event_type_id            : integer 
  #   need_transportation      : boolean 
  #   view_permission_group_id : integer 
  #   rsvp_permission_group_id : integer 
  # =======================

  has_many :blocks, :dependent => :destroy
  has_many :rsvps, :dependent => :destroy
  belongs_to :event_type
  belongs_to :view_permission_group, { :class_name => "Group" }
  belongs_to :rsvp_permission_group, { :class_name => "Group" }
  validates :name, :presence => true
  validates :location, :presence => true
  validates :description, :presence => true
  validates :event_type, :presence => true
  validate :valid_time_range

  # Hack for PST, since event times are stored as UTC even though they 
  # represent times in PST. We should resolve this eventually...
  scope :past,     joins(:event_type).where(['start_time < ?', Time.now-8.hours])
  scope :upcoming, joins(:event_type).where(['start_time > ?', Time.now-8.hours])
  scope :all,      joins(:event_type)

  scope :with_permission, Proc.new { |user| 
    if user.nil?
      where(:view_permission_group_id => nil)
    else
      where('view_permission_group_id IN (?) OR view_permission_group_id IS NULL', user.groups.map{|group| group.id})
    end
  }

  # Note on slugs: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html 
  
  def self.upcoming_events(num)
    self.with_permission(@current_user).find(:all, :conditions => ['start_time>= ?',
    Time.now], :order => "start_time asc", :limit => num)
    
  end
  
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

  def start_date
    start_time.strftime('%Y %m/%d')
  end

  def nice_time_range
    if start_time.to_date == end_time.to_date 
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%I:%M%p')}"
    else 
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%a %m/%d %I:%M%p')}"
    end 
  end

  def can_view? user
    if user.nil?
      view_permission_group.nil?
    else
      view_permission_group.nil? or user.groups.include? view_permission_group
    end
  end

  def can_rsvp? user
    if user.nil?
      false
    else
      user.groups.include? rsvp_permission_group
    end
  end

end
