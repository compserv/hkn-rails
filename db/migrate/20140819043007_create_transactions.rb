class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.belongs_to :company, null: false
      t.integer :amount, null: false
      t.string :charge_id, null: false
      t.text :description

      t.timestamps
    end

    add_index :transactions, :charge_id, unique: true
  end
end
