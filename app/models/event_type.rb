class EventType < ActiveRecord::Base

  # === List of columns ===
  #   id   : integer 
  #   name : string 
  # =======================

  validates :name, :presence => true
end
