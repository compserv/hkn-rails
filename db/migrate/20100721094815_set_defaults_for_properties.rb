class SetDefaultsForProperties < ActiveRecord::Migration
  def self.up
    change_table :properties do |t|
      t.change_default :semester, 'fa10'
      t.change_default :tutoring_enabled, false
      t.change_default :tutoring_start, 11
      t.change_default :tutoring_end, 16
    end
  end

  def self.down
    change_table :properties do |t|
      t.change_default :semester, nil
      t.change_default :tutoring_enabled, nil
      t.change_default :tutoring_start, nil
      t.change_default :tutoring_end, nil
    end
  end
end
