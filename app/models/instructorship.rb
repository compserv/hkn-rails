class Instructorship < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   klass_id      : integer 
  #   instructor_id : integer 
  #   ta            : boolean 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  # =======================

  belongs_to :klass
  belongs_to :instructor

  has_many :survey_answers

  validates_presence_of :klass
  validates_presence_of :instructor

  # Can't have multiple instructorships for same klass, and can't be both TA and instructor
  validates_uniqueness_of :instructor, :scope => [:klass]
end
