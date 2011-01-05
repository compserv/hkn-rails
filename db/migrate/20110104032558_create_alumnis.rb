class CreateAlumnis < ActiveRecord::Migration
  def self.up
    create_table :alumnis do |t|
      t.string :grad_semester
      t.string :grad_school
      t.string :job_title
      t.string :company
      t.integer :salary
      t.references :person

      t.timestamps
    end
  end

  def self.down
    drop_table :alumnis
  end
end
