# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100604063250) do

  create_table "events", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "slug"
    t.string   "location"
    t.text     "description"
    t.datetime "start_time",  :null => false
    t.datetime "end_time",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name",          :null => false
    t.string   "last_name",           :null => false
    t.string   "username",            :null => false
    t.string   "email",               :null => false
    t.string   "crypted_password",    :null => false
    t.string   "password_salt",       :null => false
    t.string   "persistence_token",   :null => false
    t.string   "single_access_token", :null => false
    t.string   "perishable_token",    :null => false
    t.string   "phone_number"
    t.string   "aim"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
