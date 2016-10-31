class CreateSlotsTutorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :slots_tutors, id: false do |t|
      t.integer :slot_id
      t.integer :tutor_id
    end
  end

  def self.down
    drop_table :slots_tutors
  end
end
