# == Schema Information
#
# Table name: course_charts
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  bias_x     :integer
#  bias_y     :integer
#  depth      :float
#  show       :boolean
#  created_at :datetime
#  updated_at :datetime
#

class CourseChart < ActiveRecord::Base
  belongs_to :course

  validates :course_id, presence: true
  validates :depth,     presence: true
end
