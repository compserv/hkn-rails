class Sellable < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   name        : string 
  #   price       : decimal 
  #   category    : string 
  #   description : text 
  #   image       : binary 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

	
  # === List of columns ======
  #   id			: integer 
  #   name		    : string 
  #   category     	: string 
  #   price     	: decimal 
  #   description   : text 
  #   image      	: binary 
  # ==========================

	validates :name,  :presence => true
  	validates :price,   :presence => true
  	validates :category, :presence=> true

end
