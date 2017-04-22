class CreateApprovedEmails < ActiveRecord::Migration
  def self.up
    create_table :approved_emails do |t|
      t.string :email,                null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :approved_emails
  end
end

