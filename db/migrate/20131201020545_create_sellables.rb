class CreateSellables < ActiveRecord::Migration
  def change
    create_table :sellables do |t|
      t.string :name
      t.decimal :price
      t.string :category
      t.text :description
      t.binary :image

      t.timestamps
    end
  end
end
