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
  
  def grade_quiz
    answers = { 
      :q1 => "University of Illinois, Urbana-Champaign",
      :q2 => "1904",
      :q3 => "Mu",
      :q4 => "1915",
      :q5_1 => "Navy Blue",
      :q5_2 => "Scarlet",
      :q6 => "wheatstone bridge",
      :q7_1 => "BRIDGE Correspondent",
      :q7_2 => "Corresponding Secretary",
      :q7_3 => "President",
      :q7_4 => "Recording Secretary",
      :q7_5 => "Vice President",
      :q7_6 => "Treasurer",
      :q8_1 => "Course Surveys",
      :q8_2 => "Exam Preparation",
      :q8_3 => "Peer Advising",
      :q8_4 => "Tutoring",
      :q9 => "Dan Garcia", #More answers?
      :q10_1 => "290 Cory",
      :q10_2 => "345 Soda"    
    }
    
    score = 0
    results = Hash.new(false)
    quiz_resp = self.quiz_responses
    if !quiz_resp.empty? #Fill hash with default blanks
      for resp in quiz_resp
        if answers[resp.number.to_sym] == resp.response
          results[resp.number.to_sym] = true
          score += 1
        end
      end
    else
      flash[:notice] = "You haven't submitted any quiz answers yet!"
    end
  end
end
