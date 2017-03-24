class AddExtraColumnsToSurveyAnswers < ActiveRecord::Migration
  def change
    add_column :survey_answers, :enrollment, :integer, default: 0
    add_column :survey_answers, :num_responses, :integer, default: 0
  end
end
