# == Schema Information
#
# Table name: event_types
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

class EventType < ActiveRecord::Base
  validates :name, :presence => true

  # Crappy pun for changing the name into a valid CSS class identifier
  def classify
    name.gsub(/\s/, '-').downcase
  end
end
