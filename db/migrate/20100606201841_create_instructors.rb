class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors do |t|
      t.string :name, :null => false
      t.string :picture
      t.string :title
      t.string :phone_number
      t.string :email
      t.string :home_page
      t.string :interests
      t.timestamps
    end
  end

  def self.down
    drop_table :instructors
  end
end
