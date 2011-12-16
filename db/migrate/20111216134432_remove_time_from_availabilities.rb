class RemoveTimeFromAvailabilities < ActiveRecord::Migration
  def change
    say "WARNING: YOU MUST DESTROY ALL CURRENT (OFFICE HOUR) Availibilities TO RUN THIS MIGRATION!"
    add_column :availabilities, :hour, :integer, :null => false
    add_column :availabilities, :wday, :integer, :null => false
    remove_column :availabilities, :time
  end
end
