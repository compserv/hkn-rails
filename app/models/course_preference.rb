class CoursePreference < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   course_id  : integer 
  #   tutor_id   : integer 
  #   level      : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================


  belongs_to :course
  belongs_to :tutor

  validates :course, :presence => true
  validates :tutor, :presence => true
  validates :level, :presence => true
  validates_numericality_of :level, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :level, :in => 0..2, :message => "invalid value." 

end
