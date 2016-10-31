class AddBookkeepingToPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.integer   :failed_login_count,  null: false, default: 0
      t.datetime  :current_login_at
    end
  end

  def self.down
    remove_column :people, :failed_login_count
    remove_column :people, :current_login_at
  end
end
