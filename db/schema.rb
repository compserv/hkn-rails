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

ActiveRecord::Schema.define(:version => 20100729043837) do

  create_table "availabilities", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "preferred_room"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preference_level"
    t.datetime "time"
  end

  create_table "blocks", :force => true do |t|
    t.integer  "rsvp_cap"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

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

  create_table "courses", :force => true do |t|
    t.string   "course_number", :null => false
    t.string   "suffix"
    t.string   "prefix"
    t.string   "name",          :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "units"
    t.string   "prereqs"
    t.integer  "department_id"
  end

  create_table "courses_in_progress_tutors", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "tutor_id"
  end

  create_table "courses_preferred_tutors", :force => true do |t|
    t.integer  "course_taking_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_taken_tutors", :force => true do |t|
    t.integer  "course_taken_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_taking_tutors", :force => true do |t|
    t.integer  "course_taking_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_tutors", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "tutor_id"
  end

  create_table "coursesurveys", :force => true do |t|
    t.integer  "max_surveyors"
    t.integer  "status"
    t.datetime "scheduled_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_id"
    t.integer  "klass",          :null => false
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.string   "abbr"
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

  create_table "exams", :force => true do |t|
    t.integer  "klass_id",    :null => false
    t.integer  "course_id",   :null => false
    t.string   "filename",    :null => false
    t.integer  "type",        :null => false
    t.integer  "number"
    t.boolean  "is_solution", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_people", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "person_id"
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

  create_table "instructors_klasses", :id => false, :force => true do |t|
    t.integer "instructor_id"
    t.integer "klass_id"
  end

  create_table "klasses", :force => true do |t|
    t.integer  "course_id",    :null => false
    t.string   "semester",     :null => false
    t.string   "location"
    t.string   "time"
    t.integer  "section"
    t.string   "notes"
    t.integer  "num_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "klasses_tas", :id => false, :force => true do |t|
    t.integer "instructor_id"
    t.integer "klass_id"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
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
    t.string   "semester",         :default => "fa10"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tutoring_enabled", :default => false
    t.text     "tutoring_message", :default => ""
    t.integer  "tutoring_start",   :default => 11
    t.integer  "tutoring_end",     :default => 16
  end

  create_table "quiz_responses", :force => true do |t|
    t.string   "number",       :null => false
    t.string   "response"
    t.integer  "candidate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rsvps", :force => true do |t|
    t.string   "confirmed"
    t.text     "confirm_comment"
    t.integer  "person_id",       :null => false
    t.integer  "event_id",        :null => false
    t.text     "comment"
    t.integer  "transportation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "block_id",        :null => false
  end

  create_table "slot_changes", :force => true do |t|
    t.integer  "tutor_id"
    t.datetime "date"
    t.integer  "add_sub"
    t.integer  "slot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slots", :force => true do |t|
    t.datetime "time"
    t.integer  "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slots_tutors", :id => false, :force => true do |t|
    t.integer "slot_id"
    t.integer "tutor_id"
  end

  create_table "tutors", :force => true do |t|
    t.integer  "person_id",  :null => false
    t.string   "languages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
