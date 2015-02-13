class AddTypeIdToCourse < ActiveRecord::Migration
  def change
    change_table :courses do |t|
      t.belongs_to :course_type, index: true
    end
  end
end
