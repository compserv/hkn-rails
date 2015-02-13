class CreateCourseCharts < ActiveRecord::Migration
  def change
    create_table :course_charts do |t|
      t.belongs_to :course, index: true
      t.integer :bias_x
      t.integer :bias_y
      t.float :depth
      t.boolean :show

      t.timestamps
    end
  end
end
