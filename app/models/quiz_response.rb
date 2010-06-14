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

end
