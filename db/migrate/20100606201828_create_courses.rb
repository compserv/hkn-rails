class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.integer :department
      t.string :course_number, null: false
      t.string :suffix
      t.string :prefix
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
