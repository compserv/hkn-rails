class AddPasswordResetToPeople < ActiveRecord::Migration
  def up
    add_column(:people, :reset_password_link, :string)
    add_column(:people, :reset_password_at, :datetime)
  end

  def down
    remove_column(:people, :reset_password_link)
    remove_column(:people, :reset_password_at)
  end
end
