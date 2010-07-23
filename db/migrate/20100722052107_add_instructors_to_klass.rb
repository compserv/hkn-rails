class AddInstructorsToKlass < ActiveRecord::Migration
  def self.up
    create_table :instructors_klasses, :id => false do |t|
      t.integer :instructor_id
      t.integer :klass_id
    end
    create_table :klasses_tas, :id => false do |t|
      t.integer :instructor_id
      t.integer :klass_id
    end
  end

  def self.down
    drop_table :instructors_klasses
    drop_table :klasses_tas
  end
end
