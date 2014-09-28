class AddReceiptSecretToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :receipt_secret, :string
  end
end
