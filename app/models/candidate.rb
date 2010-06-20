class Candidate < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person
  has_many :quiz_responses
  has_many :committee_preferences

  validates :person, :presence => true

end
