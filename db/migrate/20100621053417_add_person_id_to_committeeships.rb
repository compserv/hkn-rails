class AddPersonIdToCommitteeships < ActiveRecord::Migration
  def self.up
    add_column :committeeships, :person_id, :integer
  end

  def self.down
    remove_column :committeeships, :person_id
  end
end
