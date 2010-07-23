class AddPreferenceLevelToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :preference_level, :integer
  end

  def self.down
    remove_column :availabilities, :preference_level
  end
end
