class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id                : integer 
  #   courses_taken     : string 
  #   courses_taking    : string 
  #   preferred_courses : string 
  #   availabilities    : string 
  #   assignments       : string 
  #   languages         : string 
  #   created_at        : datetime 
  #   updated_at        : datetime 
  # =======================


  # ====== List of columns ======
  # courses_taken: Course[]
  # courses_taking: Course[]
  # preferred_course: Course[]
  # availabilities: Availability
  # assignments: Slot[]
  # programming_languages: String[]
  # ===============================

  belongs_to :person

  validates :person, :presence => true

  has_many :courses
  has_many :slots
  has_one :availability
end
