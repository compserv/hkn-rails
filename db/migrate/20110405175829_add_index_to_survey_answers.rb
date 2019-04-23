class AddIndexToSurveyAnswers < ActiveRecord::Migration
  Indices = [ [:survey_answers,   :survey_question_id],
              [:instructorships, [:klass_id, :ta]    ]
            ]

  def self.up
    Indices.each do |table, cols|
      add_index table, cols
      # execute "ANALYZE #{table.to_s}"
    end

  end

  def self.down
    Indices.each { |table, cols| remove_index table, cols }
  end
end
