class MoveAdjacencyToTutor < ActiveRecord::Migration
  def self.up
    add_column :tutors, :adjacency, :integer, :default => 0
    remove_column :availabilities, :adjacency
  end

  def self.down
    remove_column :tutors, :adjacency
    add_column :availabilities, :adjacency, :integer, :default => 0
  end
end
