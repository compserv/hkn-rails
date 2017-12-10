# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170306022053) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alumnis", force: true do |t|
    t.string   "grad_semester"
    t.string   "grad_school"
    t.string   "job_title"
    t.string   "company"
    t.integer  "salary",        limit: 8
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "perm_email"
    t.string   "location"
    t.text     "suggestions"
    t.boolean  "mailing_list"
  end

  create_table "announcements", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "availabilities", force: true do |t|
    t.integer  "tutor_id"
    t.integer  "preferred_room"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preference_level"
    t.integer  "room_strength",    default: 0
    t.string   "semester",                     null: false
    t.integer  "hour",                         null: false
    t.integer  "wday",                         null: false
  end

  create_table "badges", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "badges_people", id: false, force: true do |t|
    t.integer "badge_id"
    t.integer "person_id"
  end

  add_index "badges_people", ["badge_id", "person_id"], name: "index_badges_people_on_badge_id_and_person_id", unique: true, using: :btree

  create_table "blocks", force: true do |t|
    t.integer  "rsvp_cap"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  create_table "blocks_rsvps", id: false, force: true do |t|
    t.integer "block_id"
    t.integer "rsvp_id"
  end

  add_index "blocks_rsvps", ["block_id", "rsvp_id"], name: "index_blocks_rsvps_on_block_id_and_rsvp_id", unique: true, using: :btree

  create_table "calnet_users", force: true do |t|
    t.string   "uid"
    t.string   "name"
    t.boolean  "authorized_course_surveys"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candidates", force: true do |t|
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "committee_preferences"
    t.string   "release"
    t.integer  "quiz_score",                default: 0, null: false
    t.text     "committee_preference_note"
    t.boolean  "currently_initiating"
  end

  create_table "challenges", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "status"
    t.integer  "candidate_id"
    t.integer  "officer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_preferences", force: true do |t|
    t.integer  "group_id",     null: false
    t.integer  "candidate_id", null: false
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committeeships", force: true do |t|
    t.string   "committee"
    t.string   "semester"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
    t.string   "persistence_token",   default: "", null: false
    t.string   "single_access_token", default: "", null: false
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.text     "comments"
    t.string   "cellphone"
  end

  create_table "course_charts", force: true do |t|
    t.integer  "course_id"
    t.integer  "bias_x"
    t.integer  "bias_y"
    t.float    "depth"
    t.boolean  "show"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_charts", ["course_id"], name: "index_course_charts_on_course_id", using: :btree

  create_table "course_preferences", force: true do |t|
    t.integer  "course_id"
    t.integer  "tutor_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_preferences", ["course_id", "tutor_id"], name: "index_course_preferences_on_course_id_and_tutor_id", unique: true, using: :btree

  create_table "course_prereqs", force: true do |t|
    t.integer  "course_id",      null: false
    t.integer  "prereq_id",      null: false
    t.boolean  "is_recommended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_types", force: true do |t|
    t.float    "chart_pref_x"
    t.float    "chart_pref_y"
    t.string   "color",        limit: nil
    t.string   "name",         limit: nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.string   "suffix",         default: ""
    t.string   "prefix",         default: ""
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "units"
    t.text     "prereqs"
    t.integer  "department_id"
    t.integer  "course_number"
    t.text     "course_guide"
    t.integer  "course_type_id"
  end

  add_index "courses", ["course_type_id"], name: "index_courses_on_course_type_id", using: :btree

  create_table "coursesurveys", force: true do |t|
    t.integer  "max_surveyors",  default: 3
    t.integer  "status",         default: 0, null: false
    t.datetime "scheduled_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "klass_id",                   null: false
  end

  create_table "coursesurveys_people", id: false, force: true do |t|
    t.integer "coursesurvey_id"
    t.integer "person_id"
  end

  add_index "coursesurveys_people", ["coursesurvey_id", "person_id"], name: "index_coursesurveys_people_on_coursesurvey_id_and_person_id", unique: true, using: :btree

  create_table "departments", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dept_tour_requests", force: true do |t|
    t.string   "name"
    t.datetime "date"
    t.datetime "submitted"
    t.string   "contact"
    t.string   "phone"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "responded",  default: false
  end

  create_table "elections", force: true do |t|
    t.integer  "person_id",                        null: false
    t.string   "position"
    t.integer  "sid"
    t.integer  "keycard"
    t.boolean  "midnight_meeting", default: true
    t.boolean  "txt",              default: false
    t.string   "semester",                         null: false
    t.datetime "elected_time",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "elected",          default: false, null: false
    t.string   "non_hkn_email"
    t.string   "desired_username"
  end

  create_table "eligibilities", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_initial"
    t.string   "major"
    t.string   "email"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "semester"
    t.integer  "group",          default: 0, null: false
    t.integer  "class_level"
    t.integer  "confidence",     default: 0, null: false
    t.date     "first_reg"
    t.integer  "candidate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_types", force: true do |t|
    t.string "name", null: false
  end

  create_table "events", force: true do |t|
    t.string   "name",                                     null: false
    t.string   "slug"
    t.string   "location"
    t.text     "description"
    t.datetime "start_time",                               null: false
    t.datetime "end_time",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_type_id"
    t.boolean  "need_transportation",      default: false
    t.integer  "view_permission_group_id"
    t.integer  "rsvp_permission_group_id"
    t.boolean  "markdown",                 default: false
  end

  create_table "exams", force: true do |t|
    t.integer  "klass_id",    null: false
    t.integer  "course_id",   null: false
    t.string   "filename",    null: false
    t.integer  "exam_type",   null: false
    t.integer  "number"
    t.boolean  "is_solution", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "committee",   default: false, null: false
  end

  create_table "groups_people", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "person_id"
  end

  add_index "groups_people", ["group_id", "person_id"], name: "index_groups_people_on_group_id_and_person_id", unique: true, using: :btree

  create_table "indrel_event_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indrel_events", force: true do |t|
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

  create_table "instructors", force: true do |t|
    t.string   "last_name",                   null: false
    t.string   "picture"
    t.string   "title"
    t.string   "phone_number"
    t.string   "email"
    t.string   "home_page"
    t.text     "interests"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",      default: true
    t.string   "office"
    t.string   "first_name"
  end

  create_table "instructorships", force: true do |t|
    t.integer  "klass_id"
    t.integer  "instructor_id"
    t.boolean  "ta",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",        default: false
    t.string   "comment"
  end

  add_index "instructorships", ["klass_id", "ta"], name: "index_instructorships_on_klass_id_and_ta", using: :btree

  create_table "klasses", force: true do |t|
    t.integer  "course_id",    null: false
    t.string   "semester",     null: false
    t.string   "location"
    t.string   "time"
    t.integer  "section"
    t.text     "notes"
    t.integer  "num_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
  end

  create_table "mobile_carriers", force: true do |t|
    t.string   "name",       null: false
    t.string   "sms_email",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.string   "username",                            null: false
    t.string   "email",                               null: false
    t.string   "crypted_password",                    null: false
    t.string   "password_salt",                       null: false
    t.string   "persistence_token",                   null: false
    t.string   "single_access_token",                 null: false
    t.string   "perishable_token",                    null: false
    t.string   "phone_number"
    t.string   "aim"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.boolean  "private",             default: true,  null: false
    t.string   "local_address",       default: ""
    t.string   "perm_address",        default: ""
    t.string   "grad_semester",       default: ""
    t.boolean  "approved"
    t.integer  "failed_login_count",  default: 0,     null: false
    t.datetime "current_login_at"
    t.integer  "mobile_carrier_id"
    t.boolean  "sms_alerts",          default: false
    t.string   "reset_password_link"
    t.datetime "reset_password_at"
    t.string   "graduation"
  end

  create_table "properties", force: true do |t|
    t.string   "semester",             default: "20103"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tutoring_enabled",     default: false
    t.text     "tutoring_message",     default: ""
    t.integer  "tutoring_start",       default: 11
    t.integer  "tutoring_end",         default: 16
    t.boolean  "coursesurveys_active", default: false,   null: false
  end

  create_table "quiz_responses", force: true do |t|
    t.string   "number",                       null: false
    t.string   "response"
    t.integer  "candidate_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "correct",      default: false, null: false
  end

  create_table "resume_books", force: true do |t|
    t.string   "title"
    t.string   "pdf_file"
    t.string   "iso_file"
    t.string   "directory"
    t.string   "remarks"
    t.text     "details"
    t.date     "cutoff_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resumes", force: true do |t|
    t.decimal  "overall_gpa"
    t.decimal  "major_gpa"
    t.text     "resume_text"
    t.integer  "graduation_year"
    t.string   "graduation_semester"
    t.string   "file"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "included",            default: true, null: false
  end

  add_index "resumes", ["person_id"], name: "index_resumes_on_person_id", using: :btree

  create_table "rsvps", force: true do |t|
    t.string   "confirmed"
    t.text     "confirm_comment"
    t.integer  "person_id",       null: false
    t.integer  "event_id",        null: false
    t.text     "comment"
    t.integer  "transportation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shortlinks", force: true do |t|
    t.string   "in_url"
    t.text     "out_url"
    t.integer  "http_status", default: 301
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shortlinks", ["in_url"], name: "index_shortlinks_on_in_url", using: :btree

  create_table "slots", force: true do |t|
    t.integer  "room"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hour",       null: false
    t.integer  "wday",       null: false
  end

  create_table "slots_tutors", id: false, force: true do |t|
    t.integer "slot_id"
    t.integer "tutor_id"
  end

  add_index "slots_tutors", ["slot_id", "tutor_id"], name: "index_slots_tutors_on_slot_id_and_tutor_id", unique: true, using: :btree

  create_table "static_pages", force: true do |t|
    t.integer  "parent_id"
    t.text     "content"
    t.string   "title",      null: false
    t.string   "url",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "static_pages", ["parent_id"], name: "index_static_pages_on_parent_id", using: :btree
  add_index "static_pages", ["url"], name: "index_static_pages_on_url", using: :btree

  create_table "suggestions", force: true do |t|
    t.integer  "person_id"
    t.text     "suggestion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answers", force: true do |t|
    t.integer "survey_question_id",             null: false
    t.string  "frequencies",                    null: false
    t.float   "mean"
    t.float   "deviation"
    t.float   "median"
    t.integer "order"
    t.integer "instructorship_id",              null: false
    t.integer "enrollment",         default: 0
    t.integer "num_responses",      default: 0
  end

  add_index "survey_answers", ["instructorship_id"], name: "index_survey_answers_on_instructorship_id", using: :btree
  add_index "survey_answers", ["survey_question_id"], name: "index_survey_answers_on_survey_question_id", using: :btree

  create_table "survey_questions", force: true do |t|
    t.string  "text",                      null: false
    t.boolean "important", default: false
    t.boolean "inverted",  default: false
    t.integer "max",                       null: false
    t.integer "keyword",   default: 0
  end

  create_table "transactions", force: true do |t|
    t.integer  "amount",         null: false
    t.string   "charge_id",      null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receipt_secret"
  end

  add_index "transactions", ["charge_id"], name: "index_transactions_on_charge_id", unique: true, using: :btree

  create_table "tutors", force: true do |t|
    t.integer  "person_id",              null: false
    t.string   "languages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "adjacency",  default: 0
  end

  add_index "tutors", ["person_id"], name: "index_tutors_on_person_id", using: :btree

end
