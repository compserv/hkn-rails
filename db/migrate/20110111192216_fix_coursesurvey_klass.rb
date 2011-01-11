class FixCoursesurveyKlass < ActiveRecord::Migration
  def self.up
    rename_column :coursesurveys, :klass, :klass_id
  end

  def self.down
    rename_column :coursesurveys, :klass_id, :klass
  end
end
