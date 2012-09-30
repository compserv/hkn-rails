class AddCourseGuideToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :course_guide, :text
  end
end
