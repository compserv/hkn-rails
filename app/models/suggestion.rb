class Suggestion < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   suggestion : text 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person
end
