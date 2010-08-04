class ExtendLengthOfInstructorInterests < ActiveRecord::Migration
  def self.up
    change_column :instructors, :interests, :text
  end

  def self.down
    change_column :instructors, :interests, :string
  end
end
