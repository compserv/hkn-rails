class RenameExamTypeColumn < ActiveRecord::Migration
  def self.up
    rename_column :exams, :type, :exam_type
  end

  def self.down
    rename_column :exams, :exam_type, :type
  end
end
