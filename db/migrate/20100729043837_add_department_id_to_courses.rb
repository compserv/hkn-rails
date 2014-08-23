class AddDepartmentIdToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :department_id, :integer
    Course.reset_column_information
    Course.find_each do |c|
      c.update_attribute :department_id, c.department
    end
    remove_column :courses, :department
  end

  def self.down
    add_column :courses, :department, :integer, :null => false, :default => 0
    Course.reset_column_information
    Course.find_each do |c|
      c.update_attribute :department, c.department.id
    end
    remove_column :courses, :department_id
  end
end
