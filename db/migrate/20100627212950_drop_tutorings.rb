class DropTutorings < ActiveRecord::Migration
  def self.up
    drop_table :tutors
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
