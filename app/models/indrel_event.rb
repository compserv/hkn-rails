# == Schema Information
#
# Table name: indrel_events
#
#  id                   :integer          not null, primary key
#  time                 :datetime
#  location_id          :integer
#  indrel_event_type_id :integer
#  food                 :text
#  prizes               :text
#  turnout              :integer
#  company_id           :integer
#  contact_id           :integer
#  officer              :string(255)
#  feedback             :text
#  comments             :text
#  created_at           :datetime
#  updated_at           :datetime
#

class IndrelEvent < ActiveRecord::Base
  belongs_to :location
  belongs_to :indrel_event_type
  belongs_to :company
  belongs_to :contact

  def to_s
    "#{company} #{indel_event_type}"
  end
end
