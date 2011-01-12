class RemoveNonNullConstraintForNameOnCourse < ActiveRecord::Migration
  def self.up
    change_column :courses, :name, :string, :null => true
  end

  def self.down
    change_column :courses, :name, :string, :null => false
  end
end
