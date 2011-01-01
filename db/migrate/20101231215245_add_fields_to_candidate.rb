class AddFieldsToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :committee_preferences, :string
    add_column :candidates, :release, :string
  end

  def self.down
    remove_column :candidates, :committee_preferences
    remove_column :candidates, :release
  end
end
