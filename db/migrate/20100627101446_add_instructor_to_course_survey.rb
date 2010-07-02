class AddInstructorToCourseSurvey < ActiveRecord::Migration
  def self.up
    add_column :coursesurveys, :instructor_id, :integer
  end

  def self.down
    remove_column :coursesurveys, :instructor_id
  end
end
