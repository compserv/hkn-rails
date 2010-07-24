class AddEventIdToBlocks < ActiveRecord::Migration
  def self.up
    add_column :blocks, :event_id, :integer
  end

  def self.down
    remove_column :blocks, :event_id
  end
end
