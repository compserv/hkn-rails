class AddOrigTutorIdToTutorSwap < ActiveRecord::Migration
  def change
    add_column :tutor_swaps, :orig_tutor_id, :integer
  end
end
