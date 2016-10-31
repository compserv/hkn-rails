class AddRoomPrefStrengthToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :room_strength, :integer, default: 0
  end

  def self.down
  end
end
