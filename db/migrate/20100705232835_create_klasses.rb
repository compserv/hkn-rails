class CreateKlasses < ActiveRecord::Migration
  def self.up
    create_table :klasses do |t|

	t.references :course,:null => false
	t.string :semester, :null => false
	t.string :location
	t.string :time
	t.integer :section
	t.string :notes
	t.integer :num_students	
      t.timestamps
    end
  end

  def self.down
    drop_table :klasses
  end
end
