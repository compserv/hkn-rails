class Election < ActiveRecord::Base

  # === List of columns ===
  #   id               : integer 
  #   person_id        : integer 
  #   position         : string 
  #   sid              : integer 
  #   keycard          : integer 
  #   midnight_meeting : boolean 
  #   txt              : boolean 
  #   elected_time     : datetime 
  #   created_at       : datetime 
  #   updated_at       : datetime 
  # =======================

  belongs_to :person

  scope :current_semester, lambda { where(:elected_time => Property.current_semester_range) }

end

