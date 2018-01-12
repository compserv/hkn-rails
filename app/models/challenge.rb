# == Schema Information
#
# Table name: challenges
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  description  :text
#  status       :boolean
#  candidate_id :integer
#  officer_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Challenge < ActiveRecord::Base
  CONFIRMED = true
  REJECTED  = false
  PENDING   = nil

  belongs_to :candidate
  belongs_to :officer, class_name: "Person", foreign_key: "officer_id"

  validates :name, length: { maximum: 255 }

  scope :ordered,   lambda { order(:updated_at) }
  scope :confirmed, lambda { where(status: CONFIRMED) }
  scope :pending,   lambda { where(status: PENDING) }

  acts_as_notification do
    image ActionController::Base.helpers.asset_path("icons/notifications/challenge.jpg")
    desc  lambda { |c| "#{c.candidate.person.full_name} requested a challenge from you" }
    url   lambda { |c| '/admin/general/confirm_challenges/' }
  end

  def get_status_string
    return case status
    when CONFIRMED
      'Confirmed'
    when PENDING
      'Pending'
    when REJECTED
      'Rejected'
    else
      raise ArgumentError
    end
  end

  def is_current_challenge?
    person_id = Candidate.find_by_id(candidate_id).person_id
    current_candidate = Person.current_candidates.find_by_id(person_id)
    return current_candidate ? true : false
  end
end
