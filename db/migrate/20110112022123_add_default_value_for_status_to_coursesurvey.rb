class AddDefaultValueForStatusToCoursesurvey < ActiveRecord::Migration
  def self.up
    change_column :coursesurveys, :status, :integer, default: 0, null: false
  end

  def self.down
    change_column :coursesurveys, :status, :integer
  end
end
