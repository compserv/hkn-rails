class CreateSlot < ActiveRecord::Migration
  def self.up
    create_table :slots do |t|
      t.datetime :time
      t.integer :room

      t.timestamps
    end
  end

  def self.down
    drop_table :slots
  end
end
