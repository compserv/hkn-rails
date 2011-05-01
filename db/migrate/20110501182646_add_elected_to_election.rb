class AddElectedToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :elected, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :elections, :elected
  end
end
