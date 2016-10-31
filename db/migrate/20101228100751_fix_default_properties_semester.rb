class FixDefaultPropertiesSemester < ActiveRecord::Migration
  def self.up
    change_column_default("properties", "semester", "20103")
  end

  def self.down
    change_column_default("properties", "semester", "fa10")
  end
end
