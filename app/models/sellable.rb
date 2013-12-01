class Sellable < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   price       : decimal 
  #   category    : string 
  #   description : text 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  #   image       : string 
  # =======================

	validates :name,  :presence => true
  	validates :price,   :presence => true
  	validates :category, :presence=> true

end
