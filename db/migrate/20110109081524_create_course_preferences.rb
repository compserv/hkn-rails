class CreateCoursePreferences < ActiveRecord::Migration
  def self.up
    create_table :course_preferences do |t|
      t.references :course
      t.references :tutor
      t.integer    :level
      t.timestamps
    end
  end

  def self.down
    drop_table :course_preferences
  end
end
