class CreateCandidates < ActiveRecord::Migration
  def self.up
    create_table :candidates do |t|
      t.references :person

      t.timestamps
    end
  end

  def self.down
    drop_table :candidates
  end
end
