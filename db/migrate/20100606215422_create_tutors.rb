class CreateTutors < ActiveRecord::Migration
  def self.up
    create_table :tutors do |t|
      t.string :courses_taken
      t.string :courses_taking
      t.string :preferred_courses
      t.string :availabilities
      t.string :assignments
      t.string :languages

      t.timestamps
    end
  end

  def self.down
    drop_table :tutors
  end
end
