class AddKlassToCoursesurvey < ActiveRecord::Migration
  def self.up
    add_column :coursesurveys, :klass, :integer, null: false
  end

  def self.down
    remove_column :coursesurveys, :klass
  end
end
