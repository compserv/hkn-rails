class AddXyToCourseCharts < ActiveRecord::Migration
  def change
    add_column :course_charts, :startX, :integer, :default => 0
    add_column :course_charts, :startY, :integer, :default => 0
  end
end
