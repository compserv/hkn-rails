# == Schema Information
#
# Table name: indrel_event_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class IndrelEventType < ActiveRecord::Base
  validates_presence_of :name

  def to_s
    name
  end
end
