class FixPrecisionOnDecimalFields < ActiveRecord::Migration
  def change
    # Fix GPA decimal columns to have 4 places of precision to the right of the
    # decimal and 10 digits in general
    change_column :resumes, :overall_gpa, :decimal, precision: 10, scale: 4
    change_column :resumes, :major_gpa, :decimal, precision: 10, scale: 4
  end
end
