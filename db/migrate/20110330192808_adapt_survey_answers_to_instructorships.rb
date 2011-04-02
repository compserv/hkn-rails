class AdaptSurveyAnswersToInstructorships < ActiveRecord::Migration
  def self.up
    # Move data to temp table
    execute "SELECT *
             INTO temp_answers
             FROM survey_answers"
    execute "DELETE FROM survey_answers"

    # Change columns
    remove_index  :survey_answers, :klass_id
    remove_column :survey_answers, :instructor_id
    remove_column :survey_answers, :klass_id
    add_column :survey_answers, :instructorship_id, :integer

    # Process data
    execute "INSERT INTO survey_answers (survey_question_id, frequencies, mean, deviation, median, \"order\", instructorship_id)
             SELECT survey_question_id, frequencies, mean, deviation, median, \"order\", instructorships.id
             FROM temp_answers INNER JOIN instructorships
             ON  instructorships.klass_id      = temp_answers.klass_id
             AND instructorships.instructor_id = temp_answers.instructor_id
            "

    # Finalize
    change_column :survey_answers, :instructorship_id, :integer, :null => false
    drop_table :temp_answers

    # Remove old columns
    add_index :survey_answers, :instructorship_id
  end

  def self.down
  # TODO
  raise "Sigh, im lazy. restore a backup"
    # Restore old columns
    add_column :survey_answers, "klass_id",      :integer
    add_column :survey_answers, "instructor_id", :integer
    add_index  :survey_answers, :klass_id

    # Migrate data
    execute "INSERT INTO survey_answers (klass_id, instructor_id)
             SELECT instructorships.klass_id, instructorships.instructor_id
             FROM instructorships
             WHERE instructorships.klass_id = survey_answers.klass_id
               AND instructorships.instructor_id = survey_answers.instructor_id"

    change_column :survey_answers, :klass_id,      :integer, :null => false
    change_column :survey_answers, :instructor_id, :integer, :null => false

    # Remove instructorship
    remove_index  :survey_answers, :instructorship_id
    remove_column :survey_answers, :instructorship_id
  end
end
