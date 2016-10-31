class CreateQuizResponses < ActiveRecord::Migration
  def self.up
    create_table :quiz_responses do |t|
      # This is a string because it can contain a letter (i.e. 2b)
      t.string :number, null: false
      t.string :response
      t.references :candidate, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :quiz_responses
  end
end
