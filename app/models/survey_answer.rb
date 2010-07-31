class SurveyAnswer < ActiveRecord::Base

  # === List of columns ===
  #   id                 : integer 
  #   survey_question_id : integer 
  #   klass_id           : integer 
  #   instructor_id      : integer 
  #   frequencies        : string 
  #   mean               : float 
  #   deviation          : float 
  #   median             : float 
  #   order              : integer 
  # =======================
  
  belongs_to :klass
  belongs_to :instructor
  belongs_to :survey_question

  validates_presence_of :klass
  validates_presence_of :instructor
  validates_presence_of :survey_question

end
