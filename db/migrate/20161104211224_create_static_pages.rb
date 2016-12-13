class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.integer :parent_id
      t.text :content
      t.string :title, null: false
      t.string :url,   null: false
      t.timestamps
    end

    add_index :static_pages, :parent_id
    add_index :static_pages, :url
  end
end
