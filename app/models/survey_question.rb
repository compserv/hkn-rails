class SurveyQuestion < ActiveRecord::Base

  # === List of columns ===
  #   id        : integer 
  #   text      : string 
  #   important : boolean 
  #   inverted  : boolean 
  #   max       : integer 
  #   keyword   : integer 
  # =======================

  KEYWORDS = [:none, :prof_eff, :worthwhile, :ta_eff]

  
  validates :text, :presence => true
  validates :max,  :presence => true

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
    where(:keyword => KEYWORDS.index(value)).first
  end

  def SurveyQuestion.keyword_to_i(value)
    KEYWORDS.index(value)
  end

end
