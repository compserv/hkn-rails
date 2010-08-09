class Exam < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   klass_id    : integer 
  #   course_id   : integer 
  #   filename    : string 
  #   exam_type   : integer 
  #   number      : integer 
  #   is_solution : boolean 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  #TODO add tags
  belongs_to :klass
  belongs_to :course
  
  validates :klass, :presence => true
  validates :course, :presence => true
  validates :filename, :presence => true
  validates :exam_type, :presence => true
  validates :is_solution, :presence => true

  #Returns the name of the exam type
  def type_name
    if exam_type == 0 then
      "quiz"
    elsif exam_type == 1 then
      "midterm"
    elsif exam_type == 2 then
      "final"
    end
  end

  #Returns the abbreviation of the exam type
  def type_abbr
    if exam_type == 0 then
      "q"
    elsif exam_type == 1 then
      "mt"
    elsif exam_type == 2 then
      "f"
    end
  end
end
