class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.references :klass, null: false
      t.references :course, null: false
      t.string :filename, null: false
      t.integer :type, null: false
      t.integer :number
      t.boolean :is_solution, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end
end
