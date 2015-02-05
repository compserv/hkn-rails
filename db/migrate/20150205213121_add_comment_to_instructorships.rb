class AddCommentToInstructorships < ActiveRecord::Migration
  def change
    add_column :instructorships, :comment, :string
  end
end
