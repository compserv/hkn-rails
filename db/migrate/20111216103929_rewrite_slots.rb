class RewriteSlots < ActiveRecord::Migration
  def change
    say "WARNING: DESTROYING ALL CURRENT (OFFICE HOUR) Slots TO RUN THIS MIGRATION!"
    say "RERUN rake db:seed to fill out Slots"
    Slot.destroy_all
    add_column :slots, :hour, :integer, :null => false
    add_column :slots, :wday, :integer, :null => false
    remove_column :slots, :time
  end
end
