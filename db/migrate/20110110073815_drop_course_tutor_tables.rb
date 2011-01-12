class DropCourseTutorTables < ActiveRecord::Migration
  def self.up
    drop_table :courses_tutors
    drop_table :courses_taking_tutors
    drop_table :courses_taken_tutors
    drop_table :courses_preferred_tutors
    drop_table :courses_in_progress_tutors
  end

  def self.down
    create_table "courses_in_progress_tutors", :id => false, :force => true do |t|
      t.integer "course_id"
      t.integer "tutor_id"
    end

    create_table "courses_preferred_tutors", :force => true do |t|
      t.integer  "course_taking_id"
      t.integer  "tutor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "courses_taken_tutors", :force => true do |t|
      t.integer  "course_taken_id"
      t.integer  "tutor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "courses_taking_tutors", :force => true do |t|
      t.integer  "course_taking_id"
      t.integer  "tutor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "courses_tutors", :id => false, :force => true do |t|
      t.integer "course_id"
      t.integer "tutor_id"
    end

  end
end
