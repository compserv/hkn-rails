class CreateShortlinks < ActiveRecord::Migration
  def change
    create_table :shortlinks do |t|
      t.string :in_url
      t.text :out_url
      t.integer :http_status, default: 301
      t.references :person
      t.timestamps
    end

    add_index :shortlinks, :in_url
  end
end
