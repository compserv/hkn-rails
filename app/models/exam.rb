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

  def short_type
    "#{type_abbr}#{number}"
  end

  def file_type
    filename.split('.')[1]
  end

  def Exam.typeFromAbbr(abbr)
    @@TYPE_NUMS[abbr]
  end

  def Exam.get_dept_name_courses_tuples(dept_abbr)
    dept = Department.find_by_nice_abbr(dept_abbr)
    dept_name = dept.name
    courses = Course.where(department_id: dept.id)
                    .includes(:exams)
                    .order(:course_number)
                    .reject {|course| course.exams.empty?}
    return [dept_name, courses]
  end

end
