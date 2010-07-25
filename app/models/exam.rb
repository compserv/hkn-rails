class Exam < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   klass_id    : integer 
  #   course_id   : integer 
  #   filename    : string 
  #   type        : integer 
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
  validates :type, :presence => true
  validates :is_solution, :presence => true

  #Returns the name of the exam type
  def type_name
    if type == 0 then
      "quiz"
    elsif type == 1 then
      "midterm"
    elsif type == 2 then
      "final"
    end
  end

  #Returns the abbreviation of the exam type
  def type_abbr
    if type == 0 then
      "q"
    elsif type == 1 then
      "mt"
    elsif type == 2 then
      "f"
    end
  end

end
