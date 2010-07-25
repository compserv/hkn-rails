class Event < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   slug        : string 
  #   location    : string 
  #   description : text 
  #   start_time  : datetime 
  #   end_time    : datetime 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  has_many :blocks
  validates :name, :presence => true
  validates :location, :presence => true
  validates :description, :presence => true
  validate :valid_time_range

  # Note on slugs: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html 

  def valid_time_range
    if !start_time.blank? and !end_time.blank?
      errors[:end_time] << "must be after start time" unless start_time < end_time
    end
  end
end
