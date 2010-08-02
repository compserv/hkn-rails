class AddDefaultsToCourse < ActiveRecord::Migration
  def self.up
    change_column :courses, :prefix, :string, :default => ""
    change_column :courses, :suffix, :string, :default => ""
  end

  def self.down
    remove_column :courses, :prefix
    remove_column :courses, :suffix
  end
end
