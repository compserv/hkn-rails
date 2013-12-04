class RemoveTutorsIdFromTutorSwap < ActiveRecord::Migration
  def up
    remove_column :tutor_swaps, :tutors_id
  end

  def down
    add_column :tutor_swaps, :tutors_id, :integer
  end
end
