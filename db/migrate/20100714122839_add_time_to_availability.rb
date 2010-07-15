class AddTimeToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :time, :datetime
  end

  def self.down
    remove_column :availabilities, :time
  end
end
