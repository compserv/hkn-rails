class AddSwapDateToTutorSwap < ActiveRecord::Migration
  def change
    add_column :tutor_swaps, :swap_date, :date
  end
end
