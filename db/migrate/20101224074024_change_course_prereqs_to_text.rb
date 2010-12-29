class ChangeCoursePrereqsToText < ActiveRecord::Migration
  # Because varchar(255) isn't long enough to hold some prereq strings.

  def self.up
    change_column :courses, :prereqs, :text
  end

  def self.down
    change_column :courses, :prereqs, :string
  end
end
