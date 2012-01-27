class AddIncludedToResumes < ActiveRecord::Migration
  def change
    add_column :resumes, :included, :boolean, :default => true, :null => false
  end
end
