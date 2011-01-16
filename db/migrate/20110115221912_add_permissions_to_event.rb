class AddPermissionsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :view_permission_group_id, :integer
    add_column :events, :rsvp_permission_group_id, :integer
  end

  def self.down
    remove_column :events, :rsvp_permission_group_id
    remove_column :events, :view_permission_group_id
  end
end
