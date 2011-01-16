class Group < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   description : text 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  has_and_belongs_to_many :people
  validates :name, :presence => true, :uniqueness=>true
  validates :description, :presence => true

end
