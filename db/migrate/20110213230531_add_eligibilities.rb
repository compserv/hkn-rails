class AddEligibilities < ActiveRecord::Migration
  def self.up
    create_table :eligibilities do |t|
      [:first_name, :last_name, :middle_initial, :major, :email, :address1, :address2, :city, :state, :zip, :semester].each do |field|
        t.string field
      end

      t.integer :group, null: false, default: 0
      t.integer :class_level
      t.integer :confidence, null: false, default: 0
      t.date    :first_reg
      t.references :candidate

      t.timestamps
    end
  end

  def self.down
    drop_table :eligibilities
  end
end
