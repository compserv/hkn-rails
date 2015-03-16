class CreateCourseTypes < ActiveRecord::Migration
  def change
    create_table :course_types do |t|
      t.float :chart_pref_x
      t.float :chart_pref_y
      t.string :color
      t.string :name

      t.timestamps
    end
  end
end
