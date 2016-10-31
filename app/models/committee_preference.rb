# == Schema Information
#
# Table name: committee_preferences
#
#  id           :integer          not null, primary key
#  group_id     :integer          not null
#  candidate_id :integer          not null
#  rank         :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class CommitteePreference < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :group

  validates :group,     presence: true
  validates :candidate, presence: true
end
