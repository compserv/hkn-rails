class Tutor < ActiveRecord::Base

  # ====== List of columns ======
  # courses_taken: Course[]
  # courses_taking: Course[]
  # preferred_course: Course[]
  # availabilities: Availability
  # assignments: Slot[]
  # programming_languages: String[]
  # ===============================

  belongs_to :person

  has_many :courses
  has_many :slots
  has_one :availability
end
