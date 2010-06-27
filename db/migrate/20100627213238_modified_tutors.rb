class ModifiedTutors < ActiveRecord::Migration
  def self.up
    create_table :tutors do |t|
      t.references :person, :null => false

      t.integer :availability_id
      t.string :languages

      t.timestamps
    end

    create_table :courses_preferred_tutors do |t|
      t.integer  :course_taking_id
      t.integer  :tutor_id

      t.timestamps
    end

    create_table :courses_taken_tutors do |t|
      t.integer  :course_taken_id
      t.integer  :tutor_id

      t.timestamps
    end

    create_table :courses_taking_tutors do |t|
      t.integer  :course_taking_id
      t.integer  :tutor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tutors
    drop_table :courses_preferred_tutors
    drop_table :courses_taken_tutors
    drop_table :courses_taking_tutors
  end
end
