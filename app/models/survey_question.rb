class SurveyQuestion < ActiveRecord::Base

  # === List of columns ===
  #   id        : integer 
  #   text      : string 
  #   important : boolean 
  #   inverted  : boolean 
  #   max       : integer 
  # =======================

  
  validates :text, :presence => true
  validates :max,  :presence => true

end
