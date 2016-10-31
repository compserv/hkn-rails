# == Schema Information
#
# Table name: dept_tour_requests
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  date       :datetime
#  submitted  :datetime
#  contact    :string(255)
#  phone      :string(255)
#  comments   :text
#  created_at :datetime
#  updated_at :datetime
#  responded  :boolean          default(FALSE)
#

class DeptTourRequest < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :date
  validates_presence_of :submitted
  validates_presence_of :contact
  validates_inclusion_of :responded, in: [true, false]
end
