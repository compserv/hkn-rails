class CreateResumes < ActiveRecord::Migration
  def self.up
    create_table :resumes do |t|
      t.decimal :overall_gpa
      t.decimal :major_gpa
      t.text    :resume_text
      t.integer :graduation_year
      t.string  :graduation_semester
      t.string  :file
      t.integer :person_id

      t.timestamps
    end
    add_index :resumes, :person_id
  end

  def self.down
    drop_table :resumes
  end
end
