class ChangeRsvps < ActiveRecord::Migration
  def self.up
    create_table :blocks_rsvps, :id => false do |t|
      t.integer :block_id
      t.integer :rsvp_id
    end
    puts "Warning: Dropping all rows from rsvps, since there is a major change to RSVPs."
    Rsvp.delete_all
    remove_column :rsvps, :block_id
  end

  def self.down
    add_column :rsvps, :block_id, :integer
    drop_table :blocks_rsvps
  end
end
