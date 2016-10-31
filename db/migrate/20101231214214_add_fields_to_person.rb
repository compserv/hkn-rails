class AddFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :local_address, :string, default: ""
    add_column :people, :perm_address,  :string, default: ""
    add_column :people, :grad_semester, :string, default: ""
  end

  def self.down
    remove_column :people, :local_address
    remove_column :people, :perm_address
    remove_column :people, :grad_semester
  end
end
