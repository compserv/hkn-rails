class CreateSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_answers do |t|
      t.references :survey_question, null: false
      t.references :klass,           null: false
      t.references :instructor,      null: false
      t.string     :frequencies,     null: false
      t.float      :mean
      t.float      :deviation
      t.float      :median
      t.integer    :order
    end
  end

  def self.down
    drop_table :survey_answers
  end
end
