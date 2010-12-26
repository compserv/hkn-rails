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
    req["Mandatory for Candidates"] = 3
    req["Fun"] = 3
    req["Big Fun"] = 1
    req["Community Service"] = 2
    return req
  end

  def requirements_status
    rsvps = self.person.rsvps
    sorted_rsvps = Hash.new([])
    done = Hash.new(0)
    for rsvp in rsvps #Record finished requirements
      type = rsvp.event.event_type.name
      done[type] = done[type] + 1
      sorted_rsvps[type] << rsvp
    end
    status = Hash.new #Record status
    reqs = event_requirements
    reqs.each do |key, value|
      assign = done[key] ? done[key] >= value : false
      status[key] = assign #Set the status to true if requirement finished (cand has done >= the actual requirement value) 
    end
    return {:status => status, :rsvps => sorted_rsvps}
  end
end
