class AddQuizScoreToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :quiz_score, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :candidates, :quiz_score
  end
end
