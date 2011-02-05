class UpSalaryLimit < ActiveRecord::Migration
  def self.up
    change_column :alumnis, :salary, :bigint
  end

  def self.down
    change_column :alumnis, :salary, :integer
  end
end
