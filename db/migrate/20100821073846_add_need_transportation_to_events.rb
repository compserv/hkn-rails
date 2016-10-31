class AddNeedTransportationToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :need_transportation, :boolean, default: false
  end

  def self.down
    remove_column :events, :need_transportation
  end
end
