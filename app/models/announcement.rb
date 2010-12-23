class Announcement < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   title      : string 
  #   body       : string 
  #   person_id  : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person
end
