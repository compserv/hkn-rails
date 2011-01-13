class ChangeCourseCourseNumberFromStringToInteger < ActiveRecord::Migration
  def self.up
    add_column :courses, :new_number, :integer
    Course.reset_column_information
    Course.all.each do |course|
      (number, suffix) = course.course_number.scan(/^([0-9]+)([A-Za-z]*)$/).first
      course.new_number = number
      course.suffix = suffix unless suffix.blank?
      course.save!
    end
    remove_column :courses, :course_number
    rename_column :courses, :new_number, :course_number
  end

  def self.down
    add_column :courses, :old_number, :string
    Course.reset_column_information
    Course.all.each do |course|
      if suffix == "AC"
        course.old_number = course.course_number
      else
        course.old_number = course.course_number + course.suffix
        course.suffix = ""
      end
      course.save!
    end
    remove_column :courses, :course_number
    rename_column :courses, :old_number, :course_number
  end
end
