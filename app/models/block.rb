class Block < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   rsvp_cap   : integer 
  #   start_time : datetime 
  #   end_time   : datetime 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_many :rsvps
  
  validate :valid_time_range

  def valid_time_range
    if !start_time.blank? and !end_time.blank?
      errors[:base] << "Start time must be less than end time" unless start_time < end_time
    end
  end
end
