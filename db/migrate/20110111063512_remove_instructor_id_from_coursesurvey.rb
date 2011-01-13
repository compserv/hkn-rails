class RemoveInstructorIdFromCoursesurvey < ActiveRecord::Migration
  def self.up
    remove_column :coursesurveys, :instructor_id
  end

  def self.down
    add_column :coursesurveys, :instructor_id, :integer
    Coursesurvey.reset_column_information
    Coursesurvey.all.each do |cs|
      cs.instructor_id = cs.klass.instructor_id
      cs.save!
    end
  end
end
