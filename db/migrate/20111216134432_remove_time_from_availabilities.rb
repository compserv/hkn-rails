class RemoveTimeFromAvailabilities < ActiveRecord::Migration
  def change
    say "WARNING: DESTROYING ALL CURRENT (OFFICE HOUR) Availibilities TO RUN THIS MIGRATION!"
    Availability.destroy_all
    add_column :availabilities, :hour, :integer, :null => false
    add_column :availabilities, :wday, :integer, :null => false
    remove_column :availabilities, :time
  end
end
