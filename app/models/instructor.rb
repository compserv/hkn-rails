class Instructor < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   name         : string 
  #   picture      : string 
  #   title        : string 
  #   phone_number : string 
  #   email        : string 
  #   home_page    : string 
  #   interests    : string 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  has_many :coursesurveys

end
