class Badge < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   url        : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_and_belongs_to_many :people

  def picture_url
    return "/images/badges/" + url
  end
end
