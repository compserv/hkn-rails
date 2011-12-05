class AddSemesterToAvailability < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :semester, :string

    # Provide a one-time default
    Availability.reset_column_information
    Availability.update_all :semester => Property.current_semester

    change_column :availabilities, :semester, :string, :null => false
  end

  def self.down
    remove_column :availabilities, :semester
  end
end
