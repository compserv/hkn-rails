# == Schema Information
#
# Table name: candidates
#
#  id                        :integer          not null, primary key
#  person_id                 :integer
#  created_at                :datetime
#  updated_at                :datetime
#  committee_preferences     :string(255)
#  release                   :string(255)
#  quiz_score                :integer          default(0), not null
#  committee_preference_note :text
#  currently_initiating      :boolean
#

class Candidate < ActiveRecord::Base
  belongs_to :person
  has_many :quiz_responses
  has_many :challenges

  validates :person, presence: true
  validate :committees_must_be_valid

  scope :current, lambda { where(["candidates.created_at > ? OR currently_initiating = TRUE", Property.semester_start_time]) }
  scope :initiating, lambda { where(["currently_initiating = TRUE"]) }
  scope :approved, lambda { includes(:person).where(people: { approved: true }) }

  def self.committee_defaults
    defaults = ["Activities", "Bridge", "CompServ", "Decal", "Indrel", "Service", "StudRel", "Tutoring"]
    return defaults
  end

  def committees_must_be_valid
    defaults = Candidate.committee_defaults.collect {|c| c.downcase}
    if committee_preferences.blank?
      # nil is a valid committee
      return
    end
    for comm in committee_preferences.split
      if not defaults.include?(comm.downcase)
        errors.add(:committee_preferences, "contains invalid committees")
        return
      end
    end
  end

  def event_requirements
    req = Hash.new { |h,k| 0 }
    req["Mandatory for Candidates"] = 3
    req["Fun"] = 3
    req["Big Fun"] = 1
    req["Service"] = 1
    return req
  end

  def self.required_surveys
    1
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

    return { status: status, rsvps: sorted_rsvps }
  end

  # Updates quiz score based on submitted {quiz_responses}.
  # Grades and updates all {QuizResponse::correct}.
  def grade_quiz
    quiz_responses.each do |q|
      begin
        q.grade
        q.correct = true
      rescue QuizResponse::IncorrectError
        q.correct = false
      ensure
        q.update_attribute(:correct, q.correct) unless q.new_record?
      end
      q.save
    end

    quiz_score = quiz_responses.select(&:correct).count
    update_attribute :quiz_score, quiz_score
  end
end
