class CreateMobileCarrier < ActiveRecord::Migration
  def change
    create_table :mobile_carriers do |t|
      t.string :name, :null => false
      t.string :sms_email, :null => false
      t.timestamps
    end
  end
end
