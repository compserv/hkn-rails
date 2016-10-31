class AddSurveyorsToCoursesurvey < ActiveRecord::Migration
  def self.up
    create_table :coursesurveys_people, id: false do |t|
      t.integer :coursesurvey_id
      t.integer :person_id
    end
  end

  def self.down
    drop_table :coursesurveys_people
  end
end
