class AddBlockToRsvp < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :block_id, :integer, { null: false }
  end

  def self.down
    remove_column :rsvps, :block_id
  end
end
