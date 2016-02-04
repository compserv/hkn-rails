class CreateShortlinks < ActiveRecord::Migration
  def change
    create_table :shortlinks do |t|
      t.string :in_url
      t.text :out_url
      t.integer :http_status

      t.timestamps
    end
  end
end
