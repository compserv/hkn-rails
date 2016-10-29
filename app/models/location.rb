# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  capacity   :integer
#  created_at :datetime
#  updated_at :datetime
#  comments   :text
#

class Location < ActiveRecord::Base
  validates_presence_of :name, :capacity

  def to_s
    name
  end
end
