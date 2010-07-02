class CreateSlotChanges < ActiveRecord::Migration
  def self.up
    create_table :slot_changes do |t|
      t.integer  :tutor_id
      t.datetime :date
      t.integer  :add_sub
      t.integer  :slot_id

      t.timestamps
    end
  end

  def self.down
    drop_table :slot_changes
  end
end
