class Group < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   description : text 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  validates :name, :presence => true
  validates :description, :presence => true

end
