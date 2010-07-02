class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.string :confirmed
      t.text :confirm_comment
      t.references :person, :null => false
      t.references :event, :null => false
      t.text :comment
      t.integer :transportation

      t.timestamps
    end
  end

  def self.down
    drop_table :rsvps
  end
end
