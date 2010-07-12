class RemoveAvailabilityIdFromTutors < ActiveRecord::Migration
  def self.up
    remove_column :tutors, :availability_id
  end

  def self.down
    add_column :tutors, :availability_id, :integer
  end
end
