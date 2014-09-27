class RemoveCompanyIdFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :company_id, :integer
  end
end
