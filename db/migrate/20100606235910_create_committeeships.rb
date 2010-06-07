class CreateCommitteeships < ActiveRecord::Migration
  def self.up
    create_table :committeeships do |t|
      t.string :committee
      t.string :semester
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :committeeships
  end
end
