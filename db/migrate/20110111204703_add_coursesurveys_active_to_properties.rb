class AddCoursesurveysActiveToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :coursesurveys_active, :boolean, null: false, default: false
  end

  def self.down
    remove_column :properties, :coursesurveys_active
  end
end
