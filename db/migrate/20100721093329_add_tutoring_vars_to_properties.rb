class AddTutoringVarsToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :tutoring_enabled, :boolean
    add_column :properties, :tutoring_message, :text
    add_column :properties, :tutoring_start, :integer
    add_column :properties, :tutoring_end, :integer
  end

  def self.down
    remove_column :properties, :tutoring_end
    remove_column :properties, :tutoring_start
    remove_column :properties, :tutoring_message
    remove_column :properties, :tutoring_enabled
  end
end
