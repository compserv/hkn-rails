# == Schema Information
#
# Table name: course_types
#
#  id           :integer          not null, primary key
#  chart_pref_x :float
#  chart_pref_y :float
#  color        :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class CourseType < ActiveRecord::Base
  has_many :courses

  validates :chart_pref_x, :presence => true
  validates :chart_pref_y, :presence => true
  validates :color, :presence => true
  validates :name, :presence => true
end
