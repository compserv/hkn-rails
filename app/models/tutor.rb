class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   languages  : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person

  has_many :course_preferences
  has_many :courses, :through => :course_preferences
  has_and_belongs_to_many :slots
  has_many :availabilities

  validates :person, :presence => true
  
  def to_s
    return person.fullname
  end
end
