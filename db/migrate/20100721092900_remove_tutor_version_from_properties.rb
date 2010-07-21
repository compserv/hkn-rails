class RemoveTutorVersionFromProperties < ActiveRecord::Migration
  def self.up
    remove_column :properties, :tutor_version
  end

  def self.down
    add_column :properties, :tutor_version, :integer
  end
end
