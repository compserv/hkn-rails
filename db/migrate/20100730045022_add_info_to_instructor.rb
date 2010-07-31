class AddInfoToInstructor < ActiveRecord::Migration
  def self.up
    add_column :instructors, :private, :boolean, :default => true
    add_column :instructors, :office, :string
  end

  def self.down
    remove_column :instructors, :private
    remove_column :instructors, :office
  end
end
