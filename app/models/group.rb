# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  committee   :boolean          default(FALSE), not null
#

class Group < ActiveRecord::Base
  has_and_belongs_to_many :people
  validates :name,        presence: true, uniqueness: true
  validates :description, presence: true

  scope :committees, -> { where(committee: true) }
end
