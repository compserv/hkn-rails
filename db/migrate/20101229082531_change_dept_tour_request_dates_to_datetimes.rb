class ChangeDeptTourRequestDatesToDatetimes < ActiveRecord::Migration
  def self.up
    change_column :dept_tour_requests, :date, :datetime
    change_column :dept_tour_requests, :submitted, :datetime
  end

  def self.down
    change_column :dept_tour_requests, :date, :date
    change_column :dept_tour_requests, :submitted, :date
  end
end
