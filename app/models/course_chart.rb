class CourseChart < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   course_id   : integer 
  #   bias_x      : integer 
  #   bias_y      : integer 
  #   depth       : float 
  #   show        : boolean 
  # =======================

  belongs_to :course
  
  validates :course_id, :presence => true
  validates :depth, :presence => true

end
