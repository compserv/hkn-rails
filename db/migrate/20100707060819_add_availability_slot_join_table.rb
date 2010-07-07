class AddAvailabilitySlotJoinTable < ActiveRecord::Migration
  def self.up
    create_table :availabilities_slots, :id => false do |t|
      t.integer :availability_id
      t.integer :slot_id
    end
  end

  def self.down
    drop_table :availabilities_slots
  end
end
