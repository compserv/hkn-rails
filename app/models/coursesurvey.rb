class Coursesurvey < ActiveRecord::Base

  # === List of columns ===
  #   id             : integer 
  #   max_surveyors  : integer 
  #   status         : integer 
  #   scheduled_time : datetime 
  #   created_at     : datetime 
  #   updated_at     : datetime 
  #   instructor_id  : integer 
  # =======================

  belongs_to :instructor

  @@statusmap = { 0 => "Not Done", 1 => "Contacted", 2 => "Scheduled", 3 => "Done" }

  def get_status_text()
    @@statusmap[status]
  end
end
