class Challenge < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   name         : string 
  #   description  : text 
  #   status       : boolean 
  #   candidate_id : integer 
  #   officer_id   : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :candidate
  belongs_to :officer, :class_name => "Person", :foreign_key => "officer_id"

  validates :name, :length => { :maximum => 255 }

  #CHALLENGE_PENDING = null
  #CHALLENGE_COMPLETED = true
  #CHALLENGE_REJECTED = false

  def get_status_string
    if status
      return "Confirmed"
    else
      if status == nil
        return "Pending"
      else
        return "Rejected"
      end
    end
  end

  def is_current_challenge?
      person_id = Candidate.find_by_id(candidate_id).person_id
      current_candidate = Person.current_candidates.find_by_id(person_id)
      return current_candidate ? true : false
  end

end
