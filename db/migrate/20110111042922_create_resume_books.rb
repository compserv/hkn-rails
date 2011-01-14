class CreateResumeBooks < ActiveRecord::Migration
  def self.up
    create_table :resume_books do |t|
      t.string :title
      t.string :pdf_file
      t.string :iso_file
      t.string :directory
      t.string :remarks
      t.text   :details
      t.date   :cutoff_date

      t.timestamps
    end
  end

  def self.down
    drop_table :resume_books
  end
end
