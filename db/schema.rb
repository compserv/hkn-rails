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

ActiveRecord::Schema.define(version: 20190428201710) do

  create_table "alumnis", force: :cascade do |t|
    t.string   "grad_semester", limit: 255
    t.string   "grad_school",   limit: 255
    t.string   "job_title",     limit: 255
    t.string   "company",       limit: 255
    t.integer  "salary",        limit: 8
    t.integer  "person_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "perm_email",    limit: 255
    t.string   "location",      limit: 255
    t.text     "suggestions",   limit: 65535
    t.boolean  "mailing_list"
  end

  create_table "announcements", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "body",       limit: 255
    t.integer  "person_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "availabilities", force: :cascade do |t|
    t.integer  "tutor_id",         limit: 4
    t.integer  "preferred_room",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preference_level", limit: 4
    t.integer  "room_strength",    limit: 4,   default: 0
    t.string   "semester",         limit: 255,             null: false
    t.integer  "hour",             limit: 4,               null: false
    t.integer  "wday",             limit: 4,               null: false
  end

  create_table "badges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "badges_people", id: false, force: :cascade do |t|
    t.integer "badge_id",  limit: 4
    t.integer "person_id", limit: 4
  end

  add_index "badges_people", ["badge_id", "person_id"], name: "index_badges_people_on_badge_id_and_person_id", unique: true, using: :btree

  create_table "blocks", force: :cascade do |t|
    t.integer  "rsvp_cap",   limit: 4
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",   limit: 4
  end

  create_table "blocks_rsvps", id: false, force: :cascade do |t|
    t.integer "block_id", limit: 4
    t.integer "rsvp_id",  limit: 4
  end

  add_index "blocks_rsvps", ["block_id", "rsvp_id"], name: "index_blocks_rsvps_on_block_id_and_rsvp_id", unique: true, using: :btree

  create_table "calnet_users", force: :cascade do |t|
    t.string   "uid",                       limit: 255
    t.string   "name",                      limit: 255
    t.boolean  "authorized_course_surveys"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candidates", force: :cascade do |t|
    t.integer  "person_id",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "committee_preferences",     limit: 255
    t.string   "release",                   limit: 255
    t.integer  "quiz_score",                limit: 4,     default: 0, null: false
    t.text     "committee_preference_note", limit: 65535
    t.boolean  "currently_initiating"
  end

  create_table "challenges", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description",  limit: 65535
    t.boolean  "status"
    t.integer  "candidate_id", limit: 4
    t.integer  "officer_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_preferences", force: :cascade do |t|
    t.integer  "group_id",     limit: 4, null: false
    t.integer  "candidate_id", limit: 4, null: false
    t.integer  "rank",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committeeships", force: :cascade do |t|
    t.string   "committee",  limit: 255
    t.string   "semester",   limit: 255
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id",  limit: 4
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.text     "address",             limit: 65535
    t.string   "website",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments",            limit: 65535
    t.string   "persistence_token",   limit: 255,   default: "", null: false
    t.string   "single_access_token", limit: 255,   default: "", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id", limit: 4
    t.text     "comments",   limit: 65535
    t.string   "cellphone",  limit: 255
  end

  create_table "course_charts", force: :cascade do |t|
    t.integer  "course_id",  limit: 4
    t.integer  "bias_x",     limit: 4
    t.integer  "bias_y",     limit: 4
    t.float    "depth",      limit: 24
    t.boolean  "show"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "startX",     limit: 4,  default: 0
    t.integer  "startY",     limit: 4,  default: 0
  end

  add_index "course_charts", ["course_id"], name: "index_course_charts_on_course_id", using: :btree

  create_table "course_preferences", force: :cascade do |t|
    t.integer  "course_id",  limit: 4
    t.integer  "tutor_id",   limit: 4
    t.integer  "level",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_preferences", ["course_id", "tutor_id"], name: "index_course_preferences_on_course_id_and_tutor_id", unique: true, using: :btree

  create_table "course_prereqs", force: :cascade do |t|
    t.integer  "course_id",      limit: 4, null: false
    t.integer  "prereq_id",      limit: 4, null: false
    t.boolean  "is_recommended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_types", force: :cascade do |t|
    t.float    "chart_pref_x", limit: 24
    t.float    "chart_pref_y", limit: 24
    t.string   "color",        limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: :cascade do |t|
    t.string   "suffix",         limit: 255,   default: ""
    t.string   "prefix",         limit: 255,   default: ""
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "units",          limit: 4
    t.text     "prereqs",        limit: 65535
    t.integer  "department_id",  limit: 4
    t.integer  "course_number",  limit: 4
    t.text     "course_guide",   limit: 65535
    t.integer  "course_type_id", limit: 4
  end

  add_index "courses", ["course_type_id"], name: "index_courses_on_course_type_id", using: :btree

  create_table "coursesurveys", force: :cascade do |t|
    t.integer  "max_surveyors",  limit: 4, default: 3
    t.integer  "status",         limit: 4, default: 0, null: false
    t.datetime "scheduled_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "klass_id",       limit: 4,             null: false
  end

  create_table "coursesurveys_people", id: false, force: :cascade do |t|
    t.integer "coursesurvey_id", limit: 4
    t.integer "person_id",       limit: 4
  end

  add_index "coursesurveys_people", ["coursesurvey_id", "person_id"], name: "index_coursesurveys_people_on_coursesurvey_id_and_person_id", unique: true, using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "abbr",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dept_tour_requests", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "date"
    t.datetime "submitted"
    t.string   "contact",    limit: 255
    t.string   "phone",      limit: 255
    t.text     "comments",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "responded",                default: false
  end

  create_table "elections", force: :cascade do |t|
    t.integer  "person_id",        limit: 4,                   null: false
    t.string   "position",         limit: 255
    t.integer  "sid",              limit: 4
    t.integer  "keycard",          limit: 4
    t.boolean  "midnight_meeting",             default: true
    t.boolean  "txt",                          default: false
    t.string   "semester",         limit: 255,                 null: false
    t.datetime "elected_time",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "elected",                      default: false, null: false
    t.string   "non_hkn_email",    limit: 255
    t.string   "desired_username", limit: 255
  end

  create_table "eligibilities", force: :cascade do |t|
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.string   "middle_initial", limit: 255
    t.string   "major",          limit: 255
    t.string   "email",          limit: 255
    t.string   "address1",       limit: 255
    t.string   "address2",       limit: 255
    t.string   "city",           limit: 255
    t.string   "state",          limit: 255
    t.string   "zip",            limit: 255
    t.string   "semester",       limit: 255
    t.integer  "group",          limit: 4,   default: 0, null: false
    t.integer  "class_level",    limit: 4
    t.integer  "confidence",     limit: 4,   default: 0, null: false
    t.date     "first_reg"
    t.integer  "candidate_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_types", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",                     limit: 255,                   null: false
    t.string   "slug",                     limit: 255
    t.string   "location",                 limit: 255
    t.text     "description",              limit: 65535
    t.datetime "start_time",                                             null: false
    t.datetime "end_time",                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_type_id",            limit: 4
    t.boolean  "need_transportation",                    default: false
    t.integer  "view_permission_group_id", limit: 4
    t.integer  "rsvp_permission_group_id", limit: 4
    t.boolean  "markdown",                               default: false
  end

  create_table "exams", force: :cascade do |t|
    t.integer  "klass_id",    limit: 4,   null: false
    t.integer  "course_id",   limit: 4,   null: false
    t.string   "filename",    limit: 255, null: false
    t.integer  "exam_type",   limit: 4,   null: false
    t.integer  "number",      limit: 4
    t.boolean  "is_solution",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "committee",                 default: false, null: false
  end

  create_table "groups_people", id: false, force: :cascade do |t|
    t.integer "group_id",  limit: 4
    t.integer "person_id", limit: 4
  end

  add_index "groups_people", ["group_id", "person_id"], name: "index_groups_people_on_group_id_and_person_id", unique: true, using: :btree

  create_table "indrel_event_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indrel_events", force: :cascade do |t|
    t.datetime "time"
    t.integer  "location_id",          limit: 4
    t.integer  "indrel_event_type_id", limit: 4
    t.text     "food",                 limit: 65535
    t.text     "prizes",               limit: 65535
    t.integer  "turnout",              limit: 4
    t.integer  "company_id",           limit: 4
    t.integer  "contact_id",           limit: 4
    t.string   "officer",              limit: 255
    t.text     "feedback",             limit: 65535
    t.text     "comments",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructors", force: :cascade do |t|
    t.string   "last_name",    limit: 255,                  null: false
    t.string   "picture",      limit: 255
    t.string   "title",        limit: 255
    t.string   "phone_number", limit: 255
    t.string   "email",        limit: 255
    t.string   "home_page",    limit: 255
    t.text     "interests",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",                    default: true
    t.string   "office",       limit: 255
    t.string   "first_name",   limit: 255
  end

  create_table "instructorships", force: :cascade do |t|
    t.integer  "klass_id",      limit: 4
    t.integer  "instructor_id", limit: 4
    t.boolean  "ta",                                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",                    default: false
    t.string   "comment",       limit: 255
  end

  add_index "instructorships", ["klass_id", "ta"], name: "index_instructorships_on_klass_id_and_ta", using: :btree

  create_table "klasses", force: :cascade do |t|
    t.integer  "course_id",    limit: 4,     null: false
    t.string   "semester",     limit: 255,   null: false
    t.string   "location",     limit: 255
    t.string   "time",         limit: 255
    t.integer  "section",      limit: 4
    t.text     "notes",        limit: 65535
    t.integer  "num_students", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "capacity",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments",   limit: 65535
  end

  create_table "mobile_carriers", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "sms_email",  limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name",          limit: 255,                 null: false
    t.string   "last_name",           limit: 255,                 null: false
    t.string   "username",            limit: 255,                 null: false
    t.string   "email",               limit: 255,                 null: false
    t.string   "crypted_password",    limit: 255,                 null: false
    t.string   "password_salt",       limit: 255,                 null: false
    t.string   "persistence_token",   limit: 255,                 null: false
    t.string   "single_access_token", limit: 255,                 null: false
    t.string   "perishable_token",    limit: 255,                 null: false
    t.string   "phone_number",        limit: 255
    t.string   "aim",                 limit: 255
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture",             limit: 255
    t.boolean  "private",                         default: true,  null: false
    t.string   "local_address",       limit: 255, default: ""
    t.string   "perm_address",        limit: 255, default: ""
    t.string   "grad_semester",       limit: 255, default: ""
    t.boolean  "approved"
    t.integer  "failed_login_count",  limit: 4,   default: 0,     null: false
    t.datetime "current_login_at"
    t.integer  "mobile_carrier_id",   limit: 4
    t.boolean  "sms_alerts",                      default: false
    t.string   "reset_password_link", limit: 255
    t.datetime "reset_password_at"
    t.string   "graduation",          limit: 255
  end

  create_table "properties", force: :cascade do |t|
    t.string   "semester",             limit: 255,   default: "20103"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tutoring_enabled",                   default: false
    t.text     "tutoring_message",     limit: 65535
    t.integer  "tutoring_start",       limit: 4,     default: 11
    t.integer  "tutoring_end",         limit: 4,     default: 16
    t.boolean  "coursesurveys_active",               default: false,   null: false
  end

  create_table "quiz_responses", force: :cascade do |t|
    t.string   "number",       limit: 255,                 null: false
    t.string   "response",     limit: 255
    t.integer  "candidate_id", limit: 4,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "correct",                  default: false, null: false
  end

  create_table "resume_books", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "pdf_file",    limit: 255
    t.string   "iso_file",    limit: 255
    t.string   "directory",   limit: 255
    t.string   "remarks",     limit: 255
    t.text     "details",     limit: 65535
    t.date     "cutoff_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resumes", force: :cascade do |t|
    t.decimal  "overall_gpa",                       precision: 10, scale: 4
    t.decimal  "major_gpa",                         precision: 10, scale: 4
    t.text     "resume_text",         limit: 65535
    t.integer  "graduation_year",     limit: 4
    t.string   "graduation_semester", limit: 255
    t.string   "file",                limit: 255
    t.integer  "person_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "included",                                                   default: true, null: false
  end

  add_index "resumes", ["person_id"], name: "index_resumes_on_person_id", using: :btree

  create_table "rsvps", force: :cascade do |t|
    t.string   "confirmed",       limit: 255
    t.text     "confirm_comment", limit: 65535
    t.integer  "person_id",       limit: 4,     null: false
    t.integer  "event_id",        limit: 4,     null: false
    t.text     "comment",         limit: 65535
    t.integer  "transportation",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shortlinks", force: :cascade do |t|
    t.string   "in_url",      limit: 255
    t.text     "out_url",     limit: 65535
    t.integer  "http_status", limit: 4,     default: 301
    t.integer  "person_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shortlinks", ["in_url"], name: "index_shortlinks_on_in_url", using: :btree

  create_table "slots", force: :cascade do |t|
    t.integer  "room",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hour",       limit: 4, null: false
    t.integer  "wday",       limit: 4, null: false
  end

  create_table "slots_tutors", id: false, force: :cascade do |t|
    t.integer "slot_id",  limit: 4
    t.integer "tutor_id", limit: 4
  end

  add_index "slots_tutors", ["slot_id", "tutor_id"], name: "index_slots_tutors_on_slot_id_and_tutor_id", unique: true, using: :btree

  create_table "static_pages", force: :cascade do |t|
    t.integer  "parent_id",  limit: 4
    t.text     "content",    limit: 65535
    t.string   "title",      limit: 255,   null: false
    t.string   "url",        limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "static_pages", ["parent_id"], name: "index_static_pages_on_parent_id", using: :btree
  add_index "static_pages", ["url"], name: "index_static_pages_on_url", using: :btree

  create_table "suggestions", force: :cascade do |t|
    t.integer  "person_id",  limit: 4
    t.text     "suggestion", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer "survey_question_id", limit: 4,               null: false
    t.string  "frequencies",        limit: 255,             null: false
    t.float   "mean",               limit: 24
    t.float   "deviation",          limit: 24
    t.float   "median",             limit: 24
    t.integer "order",              limit: 4
    t.integer "instructorship_id",  limit: 4,               null: false
    t.integer "enrollment",         limit: 4,   default: 0
    t.integer "num_responses",      limit: 4,   default: 0
  end

  add_index "survey_answers", ["instructorship_id"], name: "index_survey_answers_on_instructorship_id", using: :btree
  add_index "survey_answers", ["survey_question_id"], name: "index_survey_answers_on_survey_question_id", using: :btree

  create_table "survey_questions", force: :cascade do |t|
    t.string  "text",      limit: 255,                 null: false
    t.boolean "important",             default: false
    t.boolean "inverted",              default: false
    t.integer "max",       limit: 4,                   null: false
    t.integer "keyword",   limit: 4,   default: 0
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "amount",         limit: 4,     null: false
    t.string   "charge_id",      limit: 255,   null: false
    t.text     "description",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receipt_secret", limit: 255
  end

  add_index "transactions", ["charge_id"], name: "index_transactions_on_charge_id", unique: true, using: :btree

  create_table "tutors", force: :cascade do |t|
    t.integer  "person_id",  limit: 4,               null: false
    t.string   "languages",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "adjacency",  limit: 4,   default: 0
  end

  add_index "tutors", ["person_id"], name: "index_tutors_on_person_id", using: :btree

end
