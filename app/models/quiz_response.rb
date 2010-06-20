class QuizResponse < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   number       : string 
  #   response     : string 
  #   candidate_id : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :candidate

  validates :number, :presence => true
  validates :candidate, :presence => true

end
