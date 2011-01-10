class AddAdjacencyPrefToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :adjacency, :integer, :default => 0
  end

  def self.down
  end
end
