HknRails::Application.routes.draw do

  match "test_exception_notification" => "application#test_exception_notification"

  #Department tours
  scope "dept_tour" do
    match "/" => "dept_tour#signup", :as => :dept_tour_signup
    match "success" => "dept_tour#success", :as => :dept_tour_success
  end

  # Admin Pages
  namespace :admin do
    scope "general", :as => "general" do
      match "super_page" => "admin#super_page"
      match "confirm_challenges" => "admin#confirm_challenges"
      match "confirm_challenge/:id" => "admin#confirm_challenge"
      match "reject_challenge/:id" => "admin#reject_challenge"
      # TODO: Shouldn't this be done with resources?
      scope "candidate_announcements" do
          match "/" => "admin#candidate_announcements"
          post "create_announcement" => "admin#create_announcement", :as => "create_announcement"
          match "edit_announcement/:id" => "admin#edit_announcement", :as => "edit_announcement"
          post "update_announcement" => "admin#update_announcement", :as => "update_announcement"
          match "delete_announcement/:id" => "admin#delete_announcement", :as => "delete_announcement"
      end
    end

    scope "courses", :as => "courses" do
      get  "/"    => "courses#index", :as => ''
      get  "/new"  => "courses#new", :as => 'new'
      post "/new"  => "courses#create", :as => 'create'
      get  "/:dept/:num" => "courses#show", :as => 'show'
      put  "/:dept/:num" => "courses#update", :as => 'update'

      scope '/:dept/:num/klasses', :as => 'klasses' do
        get  '/'    => 'klasses#index',  :as => ''
      end
    end

    scope 'klasses', :as => 'klasses' do
      get  '/:id' => 'klasses#edit',   :as => 'edit'
      put  '/:id' => 'klasses#update', :as => 'update'
    end

    scope "election", :as => "election" do
        get  "details"                => "elections#details",          :as => :details

        put  "edit_details/:username" => "elections#update_details",   :as => :update_details, :constraints => {:username => /.+/}
        get  "edit_details/:username" => "elections#edit_details",     :as => :edit_details,   :constraints => {:username => /.+/}

        get  "minutes"                => "elections#election_minutes", :as => :minutes
    end

    scope "pres" do
      match "/" => "pres#index", :as => :pres
    end

    scope "bridge", :as => 'bridge'  do
      get "/" => "bridge#index", :as => :index
      get "/photo_upload" => "bridge#photo_upload", :as => :photo_upload
      post "/photo_upload" => "bridge#photo_upload_post", :as => :photo_upload_post
    end

    scope "vp" do
      match "/" => "vp#index", :as => :vp
      scope "eligibilities" do
        get   "/"         => "eligibilities#list",      :as => :eligibilities
        post  "update"    => "eligibilities#update",    :as => :update_eligibilities
        post  "upload"    => "eligibilities#upload",    :as => :upload_eligibilities
        post  "reprocess" => "eligibilities#reprocess", :as => :reprocess_eligibilities
        get   "candidates.csv" => "eligibilities#csv",       :as => :eligibilities_csv
      end
      scope "cand", :as => :cand do
        get   "/"            => "applications#index", :as => :applications
        get   "byperson"     => "applications#byperson", :as => :byperson
        get   "bycommittee"  => "applications#bycommittee", :as => :bycommittee
        get   "byperson/without_application" => "applications#byperson_without_application", :as => :byperson_without_application
        post  "grade/all"    => "admin#grade_all", :as => :grade_all
      end
    end

    scope "csec", :as => "csec" do
      match "/" => "csec#index"
      get "select_classes" => "csec#select_classes", :as => :select_classes
      post "select_classes" => "csec#select_classes_post", :as => :select_classes_post
      get "manage_classes" => "csec#manage_classes", :as => :manage_classes
      post "manage_classes" => "csec#manage_classes_post", :as => :manage_classes_post
      match "manage_candidates" => "csec#manage_candidates", :as => :manage_candidates
      #post '/coursesurveys/swap/:id1/:id2' => 'csec#coursesurvey_swap', :as => :coursesurvey_swap
      get  '/coursesurveys/:id' => 'csec#coursesurvey_show', :as => :coursesurvey
      delete '/coursesurveys/:coursesurvey_id/remove/:person_id' => 'csec#coursesurvey_remove', :as => :coursesurvey_remove

      get  "upload_surveys" => "csec#upload_surveys",  :as => :upload_surveys
      post "upload_surveys" => "csec#upload_surveys_post", :as => :upload_surveys_post
    end

    scope "rsec", :as => "rsec" do
      get  "/" => "rsec#index"
      post "add_elected"                      => "rsec#add_elected",      :as => :add_elected
      match "elect/:election_id"              => "rsec#elect",            :as => :elect
      match "unelect/:election_id"             => "rsec#unelect",         :as => :unelect
      match "elections"                       => "rsec#elections",        :as => :elections
      match "find_members"                    => "rsec#find_members"
      get   "election_sheet"                  => "rsec#election_sheet",   :as => :election_sheet
      post  "commit/:election_id"             => "rsec#commit",           :as => :commit
      post  "commit_all"                      => "rsec#commit_all",       :as => :commit_all
    end # rsec

    scope "deprel" do
      match "/" => "deprel#overview"
    end
    scope "indrel" do
      match "/" => "indrel#indrel_db", :as => "indrel_db"

    end
    scope "tutor" do
      match "signup_slots" => "tutor#signup_slots", :as=>:tutor_signup_slots
      match "signup_courses" => "tutor#signup_courses", :as=>:tutor_signup_courses
      post "update_preferences" => "tutor#update_preferences", :as=>:update_course_preferences
      get "edit_schedule" => "tutor#edit_schedule", :as=>:tutor_edit_schedule
      put "update_schedule" => "tutor#update_schedule", :as=>:tutor_update_schedule
      match "params_for_scheduler" => "tutor#params_for_scheduler"
      match "/" => "tutor#settings"
      match "settings" => "tutor#settings", :as=>:tutor_settings
      match "find_courses" => "tutor#find_courses"
      match "add_course" => "tutor#add_course"
      match "update_slots" => "tutor#update_slots", :as => :tutor_update_slots
    end

    scope "studrel" do
      match "/" => "studrel#index"
    end
  end # END Admin Pages

  resources :course_preferences, :only => [:destroy]

  resources :dept_tour_requests do
    member do
      post "respond"
      #for some reason this stopped working... :(
      post "dismiss" => "dept_tour_requests#destroy"
    end
  end

  get "home/index"

  root :to => "home#index"

  # Login
  get   "login" => "user_sessions#new", :as => :login
  post  "login" => "user_sessions#create"
  match "logout" => "user_sessions#destroy", :as => :logout
  get   "reauthenticate" => "user_sessions#reauthenticate", :as => :reauthenticate
  post  "reauthenticate" => "user_sessions#reauthenticate_post"

  # Reset Password
  get  "resetpassword" => "reset_password#reset_password", :as => :reset_password
  post "resetpassword" => "reset_password#reset_password_post", :as => :reset_password_submit
  get  "resetpassword/confirm" => "reset_password#reset_password_confirm", :as => :reset_password_confirm
  post "resetpassword/confirm" => "reset_password#reset_password_confirm_post", :as => :reset_password_confirm_submit

  # Registration
  get  "register" => "people#new"
  post "register" => "people#create"

  # People
  scope "people" do
    match "list(/:category)" => "people#list", :as => :people_list
    match "contact_card"     => "people#contact_card", :as => :contact_card
  end
  match "account-settings"   => "people#edit",    :as => :account_settings
  match "people/:id/edit"    => "people#edit"
  match "people/:id/approve" => "people#approve", :as => :approve
  get   "people/:login"      => "people#show",    :as => :profile, :constraints => {:login => /[^\/]+/}
  resources :people, :except => [:new, :create, :index] do
    member do
      get  "groups", :as => :groups, :constraints => {:id => /[^\/]+/}
      post "groups" => "people#groups_update", :as => :update_groups, :constraints => {:id => /[^\/]+/}
    end
  end

  get  'leaderboard(/:semester)' => "leaderboard#index", :as => :leaderboard

  # Alumni
  resources :alumnis do
    collection do
      get 'me'
    end
  end

  scope "alumni" do
    match "registration" => "alumnis#new"
    match "newsletter" => "alumnis#newsletter"
  end

  # Resumes, this is kind of just a prototype test right now
  get "resumes/new"
  scope "resumes" do
    match "status_list" => "resumes#status_list", :as => :resumes_status_list
    match "upload" => "resumes#new", :as => :resumes_upload
    match "upload_for/:id" => "resumes#upload_for", :as => :resumes_upload_for
    match "download/:id" => "resumes#download", :as => :resume_download
    post  'include/:id' => "resumes#include", :as => :resumes_include
    post  'exclude/:id' => "resumes#exclude", :as => :resumes_exclude
  end
  resources :resumes
  scope "resume_books" do
    match "download_pdf/:id" => "resume_books#download_pdf", :as => :resume_book_download_pdf
    match "download_iso/:id" => "resume_books#download_iso", :as => :resume_book_download_iso
    match "missing" => "resume_books#missing", :as => :resume_book_missing
  end
  resources :resume_books

  # Course Guides
  scope "courseguides" do
    match "/"                              => "courseguide#index", :as => :courseguide
    match "/:dept_abbr/:course_number"     => "courseguide#show", :as => :courseguide_show
    get "/:dept_abbr/:course_number/edit"  => "courseguide#edit", :as => :courseguide_edit
    match "/:dept_abbr/:course_number/update" => "courseguide#update", :as => :courseguide_update
  end

  # Course Surveys
  scope "coursesurveys" do
    match "/"                              => "coursesurveys#index",      :as => :coursesurveys
    match "course/:dept_abbr"              => "coursesurveys#department", :as => :coursesurveys_department
    match "course/:dept_abbr/:course_number" => "coursesurveys#course", :as => :coursesurveys_course
    match "course/:dept_abbr/:short_name/:semester(/:section)" => "coursesurveys#klass",      :as => :coursesurveys_klass

    get   "instructor/new"                 => "coursesurveys#newinstructor", :as => :coursesurveys_new_instructor
    post  "instructor/new"                 => "coursesurveys#createinstructor", :as => :coursesurveys_create_instructor
    get   "instructor/:id/edit"            => "coursesurveys#editinstructor", :as => :coursesurveys_edit_instructor
    match "instructor/:id/update"          => "coursesurveys#updateinstructor", :as => :coursesurveys_update_instructor
    # This is a hack to allow periods in the parameter. Otherwise, Rails automatically splits on periods
    get   "instructor/:name"               => "coursesurveys#instructor", :as => :coursesurveys_instructor, :constraints => {:name => /.+/}
    #match ":category"                      => "coursesurveys#instructors",:as => :coursesurveys_instructors, :constraints => {:category => /(instructors)|(tas)/}
    get   "instructors"                    => "coursesurveys#instructors", :as => :coursesurveys_instructors
    get   "tas"                            => "coursesurveys#tas",         :as => :coursesurveys_tas

    match "rating/:id"                     => "coursesurveys#rating",     :as => :coursesurveys_rating
    match "rating/:id/edit"                => "coursesurveys#editrating", :as => :coursesurveys_edit_rating
    match "rating/:id/update"              => "coursesurveys#updaterating", :as => :coursesurveys_update_rating

    match "search(/:q)"                    => "coursesurveys#search",     :as => :coursesurveys_search

    match "how-to"                         => "static#coursesurveys_how_to",     :as => :coursesurveys_how_to
    match "info-profs"                     => "coursesurveys#coursesurveys_info_profs", :as => :coursesurveys_info_profs
    match "ferpa"                          => "static#coursesurveys_ferpa",      :as => :coursesurveys_ferpa

    # Admin stuff
    get   "instructor_ids"                 => "coursesurveys#instructor_ids", :as => :coursesurveys_instructor_ids
    get   "merge_instructors(/:id_0(/:id_1))"              => "coursesurveys#merge_instructors",      :as => :coursesurveys_merge_instructors
    post  "merge_instructors"              => "coursesurveys#merge_instructors_post"
  end

  match "calendar" => "events#calendar", :as => :calendar

  scope "events" do
    match "calendar" => "events#calendar", :as => :events_calendar
    match "hkn" => "events#hkn", :as => :events_ical
    match ":category" => "events#index", :as => :events_category, :constraints => {:category => /(future|past)/}

    match "rsvps" => "rsvps#my_rsvps", :as => :my_rsvps

    # Routes for RSVP confirmation page
    match "confirm_rsvps/:group" => "events#confirm_rsvps_index", :as => :confirm_rsvps_index, :constraints => {:group => /(candidates|comms)/}
    match "confirm_rsvps/:group/event/:id" => "events#confirm_rsvps", :as => :confirm_rsvps, :constraints => {:group => /(candidates|comms)/}
    match "confirm/:id" => "rsvps#confirm", :as => :confirm_rsvp
    match "unconfirm/:id" => "rsvps#unconfirm", :as => :unconfirm_rsvp
    match "reject/:id" => "rsvps#reject", :as => :reject_rsvp
    get "ical/:id" => "events#ical_single_event", :as => :single_ical
  end

  resources :events do
    collection do
      get 'ical'
    end
    resources :rsvps
    resources :blocks
  end

  resources :event_types

  # Indrel site
  scope "indrel" do
    match "/"                         => "indrel#index",                          :as => "indrel"
    match "career-fair"               => "indrel#career_fair",                    :as => "career_fair"
    match "contact-us"                => "indrel#contact_us",              :as => "indrel_contact_us"
    match "infosessions"              => "indrel#infosessions",                   :as => "infosessions"
    get   "infosessions/registration" => "indrel#infosessions_registration",      :as => "infosessions_registration"
    post  "infosessions/registration" => "indrel#infosessions_registration_post", :as => "infosessions_registration_post"
    match "resume-books"              => "indrel#resume_books",                   :as => "resume_books_about"
    get   "resume-books/order"        => "indrel#resume_books_order",             :as => "resume_books_order"
    post  "resume-books/order"        => "indrel#resume_books_order_post",        :as => "resume_books_order_post"
    resources :companies do
      member do
        post "reset_access", :as => "reset_access"
      end
    end
    resources :contacts
    resources :events,      :controller => "indrel_events",      :as => "indrel_events"
    resources :event_types, :controller => "indrel_event_types", :as => "indrel_event_types"
    resources :locations
  end

  #remove later for coming soon pages
  scope "service" do
    match "comingsoon" => "static#comingsoon"
  end

  # Static pages
  scope "about" do
    match "contact"   => "static#contact"
    match "comingsoon" => "static#comingsoon"
    match "yearbook"  => "static#yearbook"
    match "slideshow" => "static#slideshow"
    match "officers(/:semester)" => "static#officers", :as => "about_officers"
    match "cmembers(/:semester)" => "static#cmembers", :as => "about_cmembers"
  end

  #Tutoring pages
  scope "tutor" do
    match "/" => "tutor#schedule", :as => "tutor"
    match "schedule" => "tutor#schedule"
    match "calendar" => "tutor#calendar"
  end

  # Exams
  scope "exams" do
    match '/'                                     => "exams#index",
      :as => :exams
    match "search(/:q)"                                => "exams#search",
      :as => :exams_search
    match "course/:dept_abbr"                     => "exams#department",
      :as => :exams_department
    match "course/:dept_abbr/:full_course_number" => "exams#course",
      :as => :exams_course
    match 'course'                                => redirect('/exams')
    get 'new'                                     => "exams#new",
      :as => :exams_new
    post 'create'                                 => "exams#create",
      :as => :exams_create
  end
  #resources :exams

  #Candidates
  scope "cand" do
    match "portal" => "candidates#portal", :as => :candidate_portal
    match "quiz" => "candidates#quiz"
    match "application" => "candidates#application"
    match "submit_quiz" => "candidates#submit_quiz"
    match "submit_app" => "candidates#submit_app"
    match "request_challenge" => "candidates#request_challenge", :as => :request_challenge
    match "update_challenges" => "candidates#update_challenges", :as => :update_challenges
    match "find_officers" => "candidates#find_officers", :as => :find_officers
    get "coursesurvey_signup" => "candidates#coursesurvey_signup", :as => "coursesurvey_signup"
    post "coursesurvey_signup" => "candidates#coursesurvey_signup_post", :as => "coursesurvey_signup_post"
    post "promote/:id" => "candidates#promote", :as => "promote_candidate"
  end
  #resources :user_session

  scope 'notifications', :as => :notifications do
    get  '/read(.:format)' => 'notifications#index', :as => ''
  end

  # Easter Eggs
  get "easter-eggs" => "easter_eggs#edit", :as => "easter_eggs_edit"
  post "easter-eggs" => "easter_eggs#update", :as => "easter_eggs_update"
  get "sgge-retsae" => "easter_eggs#mirror", :as => "easter_eggs_mirror"
  get "b" => "easter_eggs#b", :as => "easter_eggs_b"
  get 'erection' => 'easter_eggs#erection', :as => 'erection'

  scope "console", :as => :console do
    get  "/"  => "console#open",    :as => :open
    post "/"  => "console#command", :as => :command
  end

  match "factorial/:x" => "home#factorial"

  get  'hoodies' => "static#hoodies", :as => :hoodies
end
