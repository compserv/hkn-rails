class RemoveImageFromSellables < ActiveRecord::Migration
  def up
    remove_column :sellables, :image
  end

  def down
    add_column :sellables, :image, :binary
  end
end
