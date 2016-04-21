class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.references :klass, :null => false
      t.references :course, :null => false
      t.string :topic, :null => false
      t.integer :type, :null => false
      t.string :description, :null => false
      t.string :linkfilename, :null => false

      t.timestamps
    end
  end
end
