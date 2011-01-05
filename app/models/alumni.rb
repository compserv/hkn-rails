class Alumni < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   grad_semester : string 
  #   grad_school   : string 
  #   job_title     : string 
  #   company       : string 
  #   salary        : integer 
  #   person_id     : integer 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  # =======================

  belongs_to :person
end
