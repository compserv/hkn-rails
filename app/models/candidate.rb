class Candidate < ActiveRecord::Base

  # === List of columns ===
  #   id                    : integer 
  #   person_id             : integer 
  #   created_at            : datetime 
  #   updated_at            : datetime 
  #   committee_preferences : string 
  #   release               : string 
  #   quiz_score            : integer 
  # =======================

  belongs_to :person
  has_many :quiz_responses
  has_many :challenges
  
  serialize :committee_preferences

  validates :person, :presence => true

  scope :current, lambda { where(["candidates.created_at > ?", Property.semester_start_time]) }
  
  def self.committee_defaults
    defaults = ["Activities", "Bridge", "CompServ", "Service", "Indrel", "StudRel", "Tutoring"]
    return defaults
  end
  
  def event_requirements
    req = Hash.new { |h,k| 0 }
    req["Mandatory for Candidates"] = 3
    req["Fun"] = 3
    req["Big Fun"] = 1
    req["Service"] = 2
    return req
  end

  def self.required_surveys
    3
  end

  def requirements_count
    rsvps = self.person.rsvps
    done = Hash.new(0)
    done["Mandatory for Candidates"] = 0
    done["Fun"] = 0
    done["Big Fun"] = 0
    done["Service"] = 0

    for rsvp in rsvps #Record finished requirements
      type = rsvp.event.event_type.name
      done[type] = done[type] + 1 if rsvp.confirmed == "t"
    end
    return done
  end 

  def requirements_status
    rsvps = self.person.rsvps
    sorted_rsvps = Hash.new
    done = Hash.new(0)
    for rsvp in rsvps #Record finished requirements
      type = rsvp.event.event_type.name
      done[type] = done[type] + 1 if rsvp.confirmed == "t"
      sorted_rsvps[type] = [] if sorted_rsvps[type] == nil
      sorted_rsvps[type] << rsvp
    end
    
    status = Hash.new #Record status
    reqs = event_requirements
    reqs.each do |key, value|
      sorted_rsvps[key] = [] if sorted_rsvps[key] == nil
      assign = done[key] ? done[key] >= value : false
      status[key] = assign #Set the status to true if requirement finished (cand has done >= the actual requirement value) 
    end
    
    return {:status => status, :rsvps => sorted_rsvps}
  end
  def grade_quiz
    # These are now wrapped around with regexes
    answers = { 
      :q1 => "University of Illinois, Urbana-Champaign",
      :q2 => "1904",
      :q3 => "Mu",
      :q4 => "1915",
      :q5_1 => "Navy( |-)Blue",
      :q5_2 => "Scarlet",
      :q6 => "wheatstone bridge",
      :q7_1 => "BRIDGE Correspondent",
      :q7_2 => "Corresponding Secretary",
      :q7_3 => "President",
      :q7_4 => "Recording Secretary",
      :q7_5 => "Vice( |-)President",
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
    flash ||= {}
    q7 = []
    q7_answers = ['(bridge|news) correspondent', 'corresponding secretary', 'president', 'recording secretary', 'vice-president', 'vice president', 'treasurer']
    q8 = []
    q8_answers = ['exam', 'tutor', 'course survey', 'advising', 'food run', 'review session', 'faculty retreat', 'course guide', 'department bake off', 'department bake-off', 'department tour']
    if !quiz_resp.empty? #Fill hash with default blanks
      for resp in quiz_resp
        if resp.number.to_sym == :q1
          if resp.response.downcase =~ /urbana( |-)champaign/
            results[resp.number.to_sym] = true
            resp.update_attributes! :correct => true
            score += 1
          else
            resp.update_attributes! :correct => false
          end

        elsif [:q7_1, :q7_2, :q7_3, :q7_4, :q7_5, :q7_6].include? resp.number.to_sym
          idx = q7_answers.index{|regex| resp.response.downcase =~ /^#{regex}$/}
          if idx != nil and !q7.include?(idx)
            resp.update_attributes! :correct => true
            score += 1
            q7 << idx
          else
            resp.update_attributes! :correct => false
          end

        elsif [:q8_1, :q8_2, :q8_3, :q8_4].include? resp.number.to_sym
          idx = q8_answers.index{|regex| resp.response.downcase =~ /#{regex}/}
          if idx != nil and !q8.include?(idx)
            resp.update_attributes! :correct => true
            score += 1
            q8 << idx
          else
            resp.update_attributes! :correct => false
          end

        elsif resp.number.to_sym == :q9
          if [/brewer/, /garcia/, /birdsall/, /babak/, /ayazifar/, /sahai/].delete_if{|regex| !(resp.response.downcase =~ regex)}.size >= 1
            resp.update_attributes! :correct => true
            score += 1
          else
            resp.update_attributes! :correct => false
          end

        elsif resp.number.to_sym == :q10_1
          if resp.response.downcase =~ /290 cory/ or resp.response.downcase =~ /cory 290/
            resp.update_attributes! :correct => true
            score += 1
          else
            resp.update_attributes! :correct => false
          end

        elsif resp.number.to_sym == :q10_2
          if resp.response.downcase =~ /345 soda/ or resp.response.downcase =~ /soda 345/
            resp.update_attributes! :correct => true
            score += 1
          else
            resp.update_attributes! :correct => false
          end

        elsif resp.response.downcase =~ /#{answers[resp.number.to_sym].downcase}/
          results[resp.number.to_sym] = true
          resp.update_attributes! :correct => true
          score += 1

        else
          resp.update_attributes! :correct => false
        end
      end
    else
      flash[:notice] = "You haven't submitted any quiz answers yet!"
    end
    self.quiz_score = score
    self.save!
  end
end
