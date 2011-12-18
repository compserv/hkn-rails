class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   languages  : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   adjacency  : integer 
  # =======================

  belongs_to :person

  has_many :course_preferences, :dependent => :destroy
  has_many :courses, :through => :course_preferences, :uniq => true
  has_and_belongs_to_many :slots
  has_many :availabilities

  validates :person, :presence => true

  # A current tutor has an {Election} for the current semester,
  # as given by {Property.current_semester}.
  # Also sorts by [{Person.first_name first_name}, {Person.last_name last_name}].
  scope :current, lambda { joins([:person, {:person => :elections}]).where(:elections => {:semester => Property.current_semester, :elected => true}).order(:first_name,:last_name) }
  
  def to_s
    return person.fullname
  end
end
