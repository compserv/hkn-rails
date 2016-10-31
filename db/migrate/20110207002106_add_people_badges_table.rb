class AddPeopleBadgesTable < ActiveRecord::Migration
  def self.up
    create_table :badges_people, id: false do |t|
      t.integer :badge_id
      t.integer :person_id
    end
  end


  def self.down
    drop_table :badges_people
  end
end
