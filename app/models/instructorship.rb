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

  has_many :survey_answers, :order => 'survey_answers.order', :dependent => :destroy
  has_one  :course,         :through => :klass

  validates_presence_of :klass_id
  validates_presence_of :instructor_id
  validates_inclusion_of :ta, :in => [true, false]

  # Can't have multiple instructorships for same klass, and can't be both TA and instructor
  validates_uniqueness_of :instructor_id, :scope => [:klass_id]

  def average_rating(cat=:eff)
  # Cat = :eff | :ww
  #
      survey_answers.where(:survey_question_id => SurveyQuestion.find_by_keyword(
          case cat
          when :eff then "#{ta ? 'ta' : 'prof'}_eff".to_sym
          when :ww then  :worthwhile
          else raise "Bad cat!"
          end )) .average(:mean)
  end
end
