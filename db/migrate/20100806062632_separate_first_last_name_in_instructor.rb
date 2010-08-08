class SeparateFirstLastNameInInstructor < ActiveRecord::Migration
  def self.up
    # Done this way to attempt to preserve names, but you should regenerate
    # Instructor data after running this migration.
    rename_column :instructors, :name, :last_name
    add_column    :instructors, :first_name, :string
  end

  def self.down
    rename_column :instructors, :last_name, :name
    remove_column :instructors, :first_name
  end
end
