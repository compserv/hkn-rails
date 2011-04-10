class FixKlassNotesStrings < ActiveRecord::Migration
  def self.up
    change_column :klasses, :notes, :text
  end

  def self.down
    change_column :klasses, :notes, :string
  end
end
