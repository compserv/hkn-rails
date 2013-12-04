class AddNewTutorIdToTutorSwap < ActiveRecord::Migration
  def change
    add_column :tutor_swaps, :new_tutor_id, :integer
  end
end
