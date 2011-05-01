class AddNonHknEmailToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :non_hkn_email, :string, :null => true
    add_column :elections, :desired_username, :string
  end

  def self.down
    remove_column :elections, :non_hkn_email
    remove_column :elections, :desired_username
  end
end
