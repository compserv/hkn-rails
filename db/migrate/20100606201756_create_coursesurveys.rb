class CreateCoursesurveys < ActiveRecord::Migration
  def self.up
    create_table :coursesurveys do |t|
      t.integer :max_surveyors
      t.integer :status
      t.datetime :scheduled_time
      t.timestamps
    end
  end

  def self.down
    drop_table :coursesurveys
  end
end
