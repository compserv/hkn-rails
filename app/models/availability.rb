class Availability < ActiveRecord::Base

  # === List of columns ===
  #   id               : integer 
  #   tutor_id         : integer 
  #   preferred_room   : integer 
  #   created_at       : datetime 
  #   updated_at       : datetime 
  #   preference_level : integer 
  #   time             : datetime 
  # =======================

  belongs_to :tutor

  validate :valid_room
  validates :tutor, :presence => true
  validates :preference_level, :presence => true
  
  @prefstr_to_int = {"unavailable"=>0,"available"=>1,"preferred"=>2}
  class << self
    attr_reader :prefstr_to_int
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
end
