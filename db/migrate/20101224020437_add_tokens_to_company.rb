class AddTokensToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :persistence_token,   :string, null: false, default: ""
    add_column :companies, :single_access_token, :string, null: false, default: ""
  end

  def self.down
    remove_column :companies, :single_access_token
    remove_column :companies, :persistence_token
  end
end
