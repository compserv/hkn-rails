class Klass < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   course_id    : integer 
  #   semester     : string 
  #   location     : string 
  #   time         : string 
  #   section      : integer 
  #   notes        : string 
  #   num_students : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :course

end
