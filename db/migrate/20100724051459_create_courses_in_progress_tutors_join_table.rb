class CreateCoursesInProgressTutorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :courses_in_progress_tutors, id: false do |t|
      t.integer :course_id
      t.integer :tutor_id
    end
  end

  def self.down
    drop_table :courses_in_progress_tutors
  end
end
