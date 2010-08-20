class AddEventTypeToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_type_id, :integer
  end

  def self.down
    drop_column :events, :event_type_id
  end
end
