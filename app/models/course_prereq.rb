class CoursePrereq < ActiveRecord::Base

  # === List of columns ===
  #   id              : integer 
  #   course_id       : integer 
  #   prereq_id       : integer 
  #   is_recommended  : boolean 
  # =======================

  belongs_to :course, :class_name => :Course
  belongs_to :prereq, :class_name => :Course
  
  validates :course_id, :presence => true
  validates :prereq_id, :presence => true
end
