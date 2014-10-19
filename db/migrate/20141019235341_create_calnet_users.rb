class CreateCalnetUsers < ActiveRecord::Migration
  def change
    create_table :calnet_users do |t|
      t.string :uid
      t.string :name
      t.boolean :authorized_course_surveys

      t.timestamps
    end
  end
end
