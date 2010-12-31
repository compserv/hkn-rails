class CreateDeptTourRequests < ActiveRecord::Migration
  def self.up
    create_table :dept_tour_requests do |t|
      t.string :name
      t.date :date
      t.date :submitted
      t.string :contact
      t.string :phone
      t.string :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :dept_tour_requests
  end
end
