class CreateAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :availabilities do |t|
      t.integer :tutor_id
      t.integer :preferred_room

      t.timestamps
    end

    create_table :availabilities_times do |t|
      t.integer :availability_id
      t.datetime :time

      t.timestamps
    end
  end

  def self.down
    drop_table :availabilities
    drop_table :availabilities_times
  end
end
