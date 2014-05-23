class Group < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   description : text 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  #   committee   : boolean 
  # =======================

  has_and_belongs_to_many :people
  validates :name, :presence => true, :uniqueness=>true
  validates :description, :presence => true

  scope :committees, -> { where(:committee => true) }

end
