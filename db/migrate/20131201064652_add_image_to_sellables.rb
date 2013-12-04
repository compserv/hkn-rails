class AddImageToSellables < ActiveRecord::Migration
  def change
    add_column :sellables, :image, :string
  end
end
