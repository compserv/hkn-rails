class CreateSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :survey_questions do |t|
      t.string  :text,      :null => false
      t.boolean :important, :default => false
      t.boolean :inverted,  :default => false
      t.integer :max,       :null => false
    end
  end

  def self.down
    drop_table :survey_questions
  end
end
