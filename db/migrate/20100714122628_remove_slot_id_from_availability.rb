class RemoveSlotIdFromAvailability < ActiveRecord::Migration
  def self.up
      remove_column :availabilities, :slot_id
  end

  def self.down
    add_column :availabilities, :slot_id, :integer
  end
end
