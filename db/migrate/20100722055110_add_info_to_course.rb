class AddInfoToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :units, :integer
    add_column :courses, :prereqs, :string
  end

  def self.down
    remove_column :courses, :units
    remove_column :courses, :prereqs
  end
end
