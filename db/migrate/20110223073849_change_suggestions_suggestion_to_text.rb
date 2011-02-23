class ChangeSuggestionsSuggestionToText < ActiveRecord::Migration
  def self.up
    change_column :suggestions, :suggestion, :text
  end

  def self.down
    change_column :suggestions, :suggestion, :string
  end
end
