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
  has_many :coursesurveys
  has_and_belongs_to_many :instructors
  # tas = TAs
  has_and_belongs_to_many :tas, { :class_name => "Instructor", :join_table => "klasses_tas" }
  has_many :exams

end
