class AddCurrentlyInitiatingToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :currently_initiating, :boolean
  end
end
