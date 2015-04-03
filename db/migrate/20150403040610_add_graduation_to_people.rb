class AddGraduationToPeople < ActiveRecord::Migration
  def change
    add_column :people, :graduation, :string
  end
end
