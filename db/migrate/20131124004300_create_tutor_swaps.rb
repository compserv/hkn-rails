class CreateTutorSwaps < ActiveRecord::Migration
  def change
    create_table :tutor_swaps do |t|
      t.references :tutors
      t.references :slot

      t.timestamps
    end
    add_index :tutor_swaps, :tutors_id
    add_index :tutor_swaps, :slot_id
  end
end
