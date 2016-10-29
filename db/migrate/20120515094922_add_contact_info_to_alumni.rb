class AddContactInfoToAlumni < ActiveRecord::Migration
  def up
    add_column :alumnis, :perm_email, :string
    add_column :alumnis, :location, :string
    add_column :alumnis, :suggestions, :text
    add_column :alumnis, :mailing_list, :boolean
  end

  def down
    remove_column :alumnis, :perm_email
    remove_column :alumnis, :location
    remove_column :alumnis, :suggestions
    remove_column :alumnis, :mailing_list
  end
end
