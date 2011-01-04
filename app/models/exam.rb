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
  validates_inclusion_of :is_solution, :in => [true, false]

  @@TYPE_ABBRS = { 0 => 'q', 1 => 'mt', 2 => 'f' }
  @@TYPE_NAMES = { 0 => 'quiz', 1 => 'midterm', 2 => 'final'}
  @@TYPE_NUMS = {'q' => 0, 'mt' => 1, 'f' => 2 }

  #Returns the name of the exam type
  def type_name
    @@TYPE_NAMES[exam_type]
  end

  #Returns the abbreviation of the exam type
  def type_abbr
    @@TYPE_ABBRS[exam_type]
  end

  def Exam.typeFromAbbr(abbr)
    @@TYPE_NUMS[abbr]
  end
end
