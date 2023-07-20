# == Schema Information
#
# Table name: survey_questions
#
#  id        :integer          not null, primary key
#  text      :string(255)      not null
#  important :boolean          default(FALSE)
#  inverted  :boolean          default(FALSE)
#  max       :integer          not null
#  keyword   :integer          default(0)
#

class SurveyQuestion < ActiveRecord::Base
  KEYWORDS = [:none, :prof_eff, :worthwhile, :ta_eff]


  validates :text, presence: true
  validates :max,  presence: true

  searchable do
    text :text
  end

  def keyword
    KEYWORDS[read_attribute(:keyword)]
  end

  def keyword=(value)
    raise "Not a valid value. Valid values include [#{KEYWORDS.join(", ")}]" unless KEYWORDS.include? value
    write_attribute(:keyword, KEYWORDS.index(value))
  end

  def SurveyQuestion.find_by_keyword(value)
    where(keyword: KEYWORDS.index(value)).first
  end
  
  def SurveyQuestion.find_all_by_keyword(value)
    where(keyword: KEYWORDS.index(value))
  end

  def SurveyQuestion.keyword_to_i(value)
    KEYWORDS.index(value)
  end

end
