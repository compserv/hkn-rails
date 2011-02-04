class AddApprovedToPerson < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.boolean :approved, :default => nil
    end
    Person.update_all ["approved = ?", true]
  end

  def self.down
    remove_column :people, :approved
  end
end
