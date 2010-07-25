class Block < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   rsvp_cap   : integer 
  #   start_time : datetime 
  #   end_time   : datetime 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   event_id   : integer 
  # =======================

  has_many :rsvps
  belongs_to :event

  validate :valid_time_range
  validates :event, :presence => true

  def valid_time_range
    if !start_time.blank? and !end_time.blank?
      errors[:end_time] << "must be after start time" unless start_time < end_time
    end
  end
end
