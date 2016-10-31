class CreateCommitteePreferences < ActiveRecord::Migration
  def self.up
    create_table :committee_preferences do |t|
      t.references :group, null: false
      t.references :candidate, null: false
      t.integer :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_preferences
  end
end
