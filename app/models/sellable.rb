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

	validates	:name,		presence: true
  	validates 	:price,		presence: true
  	validates 	:category,	presence: true
  	validates 	:image, 	presence: true

  	# Returns the raw location for saving purposes
  	def image_location()
  		return "public/pictures/product_images/#{id}.png"
  	end

  	# Save the image field, so image_tag(product.image) can be used
  	def initialize_image_field()
  		image = "/pictures/product_images/#{id}.png"
  	end


end
