class AddCorrectToQuizResponse < ActiveRecord::Migration
  def self.up
    add_column :quiz_responses, :correct, :boolean, null: false, default: false
  end

  def self.down
    remove_column :quiz_responses, :correct
  end
end
