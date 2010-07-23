class DropAvailabilitySlotJoinTable < ActiveRecord::Migration
  def self.up
    drop_table :availabilities_slots
  end

  def self.down
    create_table :availabilities_slots, :id => false do |t|
      t.integer :availability_id
      t.integer :slot_id
    end
  end
end
