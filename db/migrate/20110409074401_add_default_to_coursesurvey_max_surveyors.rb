class AddDefaultToCoursesurveyMaxSurveyors < ActiveRecord::Migration
  def self.up
    change_column_default :coursesurveys, :max_surveyors, 3
  end

  def self.down
    change_column_default :coursesurveys, :max_surveyors, nil
  end
end
