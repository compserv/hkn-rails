class CreateChallenges < ActiveRecord::Migration
  def self.up
    create_table :challenges do |t|
      t.string :name
      t.string :description
      t.boolean :status
      t.integer :candidate_id
      t.integer :officer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :challenges
  end
end
