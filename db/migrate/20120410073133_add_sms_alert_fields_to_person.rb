class AddSmsAlertFieldsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :mobile_carrier_id, :integer
    add_column :people, :sms_alerts, :boolean, default: false
  end
end
