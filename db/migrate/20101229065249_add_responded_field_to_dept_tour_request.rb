class AddRespondedFieldToDeptTourRequest < ActiveRecord::Migration
  def self.up
    add_column :dept_tour_requests, :responded, :boolean, :default => false
  end

  def self.down
    remove_column :dept_tour_requests, :responded
  end
end
