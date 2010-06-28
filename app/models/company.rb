class Company < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   address    : text 
  #   website    : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   comments   : text 
  # =======================

  has_many  :contacts
  validates_presence_of :name
  
  def to_s
    name
  end
end
