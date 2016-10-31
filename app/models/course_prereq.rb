# == Schema Information
#
# Table name: course_prereqs
#
#  id             :integer          not null, primary key
#  course_id      :integer          not null
#  prereq_id      :integer          not null
#  is_recommended :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

class CoursePrereq < ActiveRecord::Base
  belongs_to :course, class_name: :Course
  belongs_to :prereq, class_name: :Course

  validates :course_id, presence: true
  validates :prereq_id, presence: true
end
