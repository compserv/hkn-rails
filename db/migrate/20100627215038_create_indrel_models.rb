class CreateIndrelModels < ActiveRecord::Migration
  def self.up
    create_table "companies", :force => true do |t|
      t.string   "name"
      t.text     "address"
      t.string   "website"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "comments"
    end

    create_table "contacts", :force => true do |t|
      t.string   "name"
      t.string   "email"
      t.string   "phone"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "company_id"
      t.text     "comments"
      t.string   "cellphone"
    end

    create_table "indrel_event_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "indrel_events", :force => true do |t|
      t.datetime "time"
      t.integer  "location_id"
      t.integer  "indrel_event_type_id"
      t.text     "food"
      t.text     "prizes"
      t.integer  "turnout"
      t.integer  "company_id"
      t.integer  "contact_id"
      t.string   "officer"
      t.text     "feedback"
      t.text     "comments"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "locations", :force => true do |t|
      t.string   "name"
      t.integer  "capacity"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "comments"
    end
  end

  def self.down
    drop_table :companies
    drop_table :contacts
    drop_table :indrel_event_types
    drop_table :indrel_events
    drop_table :locations
  end
end
