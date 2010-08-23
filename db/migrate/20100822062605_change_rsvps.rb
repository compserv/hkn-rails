class ChangeRsvps < ActiveRecord::Migration
  def self.up
    puts "Warning: Dropping all rows from rsvps"
    Rsvp.delete_all
    create_table :blocks_rsvps, :id => false do |t|
      t.integer :block_id
      t.integer :rsvp_id
    end
    remove_column :rsvps, :block_id
  end

  def self.down
    add_column :rsvps, :block_id, :integer
    drop_table :blocks_rsvps
  end
end
