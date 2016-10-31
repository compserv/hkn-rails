# == Schema Information
#
# Table name: coursesurveys
#
#  id             :integer          not null, primary key
#  max_surveyors  :integer          default(3)
#  status         :integer          default(0), not null
#  scheduled_time :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  klass_id       :integer          not null
#

class Coursesurvey < ActiveRecord::Base
  belongs_to :klass
  has_and_belongs_to_many :surveyors, { class_name: "Person" , uniq: true }

  validates :klass_id, presence: true, uniqueness: true
  validates :max_surveyors, numericality: true
  validates :status, presence: true, numericality: true

  scope :current_semester, lambda { joins(klass: :course).where('klasses.semester' => Property.get_or_create.semester).order('courses.department_id, courses.prefix, courses.course_number, courses.suffix ASC, section') }

  @@statusmap = { 0 => "Not Done", 1 => "Contacted", 2 => "Scheduled", 3 => "Done" }

  def get_status_text()
    @@statusmap[status]
  end

  def self.statusmap
    @@statusmap
  end

  def full?
    if max_surveyors.nil?
      return true
    else
      return surveyors.count >= max_surveyors
    end
  end
end
