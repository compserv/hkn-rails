class CreateCoursePrereqs < ActiveRecord::Migration
  def change
    create_table :course_prereqs do |t|
      t.integer :course_id, null: false
      t.integer :prereq_id, null: false
      t.boolean :is_recommended

      t.timestamps
    end
  end
end
