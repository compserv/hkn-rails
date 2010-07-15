class DropAvailabilitiesTimesTable < ActiveRecord::Migration
  def self.up
    drop_table :availabilities_times
  end

  def self.down
    create_table :availabilities_times do |t|
      t.integer :availability_id
      t.datetime :time

      t.timestamps
    end
  end
end
