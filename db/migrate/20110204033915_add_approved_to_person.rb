class AddApprovedToPerson < ActiveRecord::Migration
  class Person < ActiveRecord::Base
  end

  def self.up
    add_column :people, :approved, :boolean, default: nil
    Person.update_all approved: true
  end

  def self.down
    remove_column :people, :approved
  end
end
