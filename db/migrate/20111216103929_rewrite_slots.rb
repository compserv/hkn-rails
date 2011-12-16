class RewriteSlots < ActiveRecord::Migration
  def change
    say "WARNING: YOU MUST DESTROY ALL CURRENT (OFFICE HOUR) Slots TO RUN THIS MIGRATION!"
    add_column :slots, :hour, :integer, :null => false
    add_column :slots, :wday, :integer, :null => false
    remove_column :slots, :time
  end
end
