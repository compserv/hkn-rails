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
  #   private      : boolean 
  #   office       : string 
  # =======================

  has_many :coursesurveys
  has_and_belongs_to_many :klasses
  has_and_belongs_to_many :ta_klasses, { :class_name => "Klass", :join_table => "klasses_tas" }

end
