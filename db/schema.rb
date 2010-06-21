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

ActiveRecord::Schema.define(:version => 20100621053417) do

  create_table "candidates", :force => true do |t|
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_preferences", :force => true do |t|
    t.integer  "group_id",     :null => false
    t.integer  "candidate_id", :null => false
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committeeships", :force => true do |t|
    t.string   "committee"
    t.string   "semester"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
  end

  create_table "courses", :force => true do |t|
    t.integer  "department"
    t.string   "course_number", :null => false
    t.string   "suffix"
    t.string   "prefix"
    t.string   "name",          :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coursesurveys", :force => true do |t|
    t.integer  "max_surveyors"
    t.integer  "status"
    t.datetime "scheduled_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructors", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "picture"
    t.string   "title"
    t.string   "phone_number"
    t.string   "email"
    t.string   "home_page"
    t.string   "interests"
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

  create_table "properties", :force => true do |t|
    t.integer  "tutor_version"
    t.string   "semester"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_responses", :force => true do |t|
    t.string   "number",       :null => false
    t.string   "response"
    t.integer  "candidate_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tutors", :force => true do |t|
    t.string   "courses_taken"
    t.string   "courses_taking"
    t.string   "preferred_courses"
    t.string   "availabilities"
    t.string   "assignments"
    t.string   "languages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
