class AddHiddenToInstructorship < ActiveRecord::Migration
  def change
    add_column :instructorships, :hidden, :boolean, :default => false
  end
end
