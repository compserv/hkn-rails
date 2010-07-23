class AddSlotIdToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :slot_id, :integer
  end

  def self.down
    remove_column :availabilities, :slot_id
  end
end
