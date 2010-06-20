class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.integer :tutor_version
      t.string :semester

      t.timestamps
    end
  end

  def self.down
    drop_table :properties
  end
end
