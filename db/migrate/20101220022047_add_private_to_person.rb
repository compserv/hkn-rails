class AddPrivateToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :private, :boolean, default: true, null: false
  end

  def self.down
    remove_column :people, :private
  end
end
