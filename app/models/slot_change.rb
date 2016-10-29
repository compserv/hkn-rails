# == Schema Information
#
# Table name: slot_changes
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  date       :datetime
#  add_sub    :integer
#  slot_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class SlotChange < ActiveRecord::Base
  belongs_to :tutor

  validates :tutor, :presence => true
  validate :valid_add_sub

  def valid_add_sub
    errors[:add_sub] << "Must be either 0 (add) or 1 (subtract)" unless (add_sub == 0 or add_sub == 1)
  end

  def get_type()
    if type == 0 then
      "Add"
    elsif type == 1 then
      "Subtract"
    end
  end
end
