class FixDeptTourStrings < ActiveRecord::Migration
  def self.up
    change_column :dept_tour_requests, :comments, :text
  end

  def self.down
    change_column :dept_tour_requests, :comments, :string
  end
end
