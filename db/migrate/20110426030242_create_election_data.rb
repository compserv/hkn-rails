class CreateElectionData < ActiveRecord::Migration
  def self.up
    create_table :elections do |t|
      t.references :person,         :null => false

      # Additional info not present in person (see the google doc)
      t.string   :position,         :null => :false
      t.integer  :sid,              :null => :false
      t.integer  :keycard,          :null => :false
      t.boolean  :midnight_meeting, :null => :false, :default => true
      t.boolean  :txt,              :null => :false, :default => false

      t.datetime :elected_time

      t.timestamps
    end # create_table
  end

  def self.down
    drop_table :elections
  end
end
