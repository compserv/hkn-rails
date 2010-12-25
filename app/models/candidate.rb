class Candidate < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  belongs_to :person
  has_many :quiz_responses
  has_many :challenges
  has_many :committee_preferences

  validates :person, :presence => true
  
  def event_requirements
    req = Hash.new
    req["Mandatory for Candidates"] = -1
    req["Fun"] = 3
    req["Big Fun"] = 1
    req["Community Service"] = 2
  end

  def requirements_status
    rsvps = self.person.rsvps
    done = Hash.new
    for rsvp in rsvps #Record finished requirements
      event = rsvp.event
      done[event.event_type] = done[event.event_type] + 1
    end
    status = Hash.new #Record status
    reqs = event_requirements
    reqs.each do |key, value|
      
    end
    return {:status => status, :rsvps => rsvps}
  end
end
