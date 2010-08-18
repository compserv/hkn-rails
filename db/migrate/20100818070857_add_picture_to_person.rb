class AddPictureToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :picture, :string
  end

  def self.down
    remove_column :people, :picture
  end
end
