class DropSlotChanges < ActiveRecord::Migration
  def self.up
    drop_table :slot_changes
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
