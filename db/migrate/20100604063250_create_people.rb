class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name,           null: false
      t.string :last_name,            null: false
      t.string :username,             null: false
      t.string :email,                null: false

      t.string :crypted_password,     null: false
      t.string :password_salt,        null: false
      t.string :persistence_token,    null: false
      t.string :single_access_token,  null: false
      t.string :perishable_token,     null: false

      t.string :phone_number
      t.string :aim
      t.date   :date_of_birth

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
