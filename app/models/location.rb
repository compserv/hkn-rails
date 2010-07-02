class Location < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   capacity   : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   comments   : text 
  # =======================

  validates_presence_of :name, :capacity

  def to_s
    name
  end
end
