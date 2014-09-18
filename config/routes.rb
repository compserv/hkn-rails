HknRails::Application.routes.draw do

  get "test_exception_notification" => "application#test_exception_notification"

  #Department tours
  scope "dept_tour" do
    match "/" => "dept_tour#signup", :as => :dept_tour_signup, :via => [:get, :post]
    match "success" => "dept_tour#success", :as => :dept_tour_success, :via => [:get, :post]
  end

  # Admin Pages
  namespace :admin do
    scope "general", :as => "general" do
      match "super_page" => "admin#super_page", :via => [:get, :post]
      match "confirm_challenges" => "admin#confirm_challenges", :via => [:get, :post]
      match "confirm_challenge/:id" => "admin#confirm_challenge", :via => [:get, :post]
      match "reject_challenge/:id" => "admin#reject_challenge", :via => [:get, :post]
      # TODO: Shouldn't this be done with resources?
      scope "candidate_announcements" do
          match "/" => "admin#candidate_announcements", :via => [:get, :post]
          post "create_announcement" => "admin#create_announcement", :as => "create_announcement"
          match "edit_announcement/:id" => "admin#edit_announcement", :as => "edit_announcement", :via => [:get, :post]
          post "update_announcement" => "admin#update_announcement", :as => "update_announcement"
          match "delete_announcement/:id" => "admin#delete_announcement", :as => "delete_announcement", :via => [:get, :post]
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
      patch  '/:id' => 'klasses#update', :as => 'update'
    end

    scope "election", :as => "election" do
        get  "details"                => "elections#details",          :as => :details

        put  "edit_details/:username" => "elections#update_details",   :as => :update_details, :constraints => {:username => /.+/}
        get  "edit_details/:username" => "elections#edit_details",     :as => :edit_details,   :constraints => {:username => /.+/}

        get  "minutes"                => "elections#election_minutes", :as => :minutes
    end

    scope "pres" do
      match "/" => "pres#index", :as => :pres, :via => [:get, :post]
    end

    scope "bridge", :as => 'bridge'  do
      get "/" => "bridge#index", :as => :index
      get "/photo_upload" => "bridge#photo_upload", :as => :photo_upload
      post "/photo_upload" => "bridge#photo_upload_post", :as => :photo_upload_post
    end

    scope "vp" do
      match "/" => "vp#index", :as => :vp, :via => [:get, :post]
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
      match "/" => "csec#index", :via => [:get, :post]
      get "select_classes" => "csec#select_classes", :as => :select_classes
      post "select_classes" => "csec#select_classes_post", :as => :select_classes_post
      get "manage_classes" => "csec#manage_classes", :as => :manage_classes
      post "manage_classes" => "csec#manage_classes_post", :as => :manage_classes_post
      match "manage_candidates" => "csec#manage_candidates", :as => :manage_candidates, :via => [:get, :post]
      #post '/coursesurveys/swap/:id1/:id2' => 'csec#coursesurvey_swap', :as => :coursesurvey_swap
      get  '/coursesurveys/:id' => 'csec#coursesurvey_show', :as => :coursesurvey
      delete '/coursesurveys/:coursesurvey_id/remove/:person_id' => 'csec#coursesurvey_remove', :as => :coursesurvey_remove

      get  "upload_surveys" => "csec#upload_surveys",  :as => :upload_surveys
      post "upload_surveys" => "csec#upload_surveys_post", :as => :upload_surveys_post
    end

    scope "rsec", :as => "rsec" do
      get  "/" => "rsec#index"
      post "add_elected"                      => "rsec#add_elected",      :as => :add_elected
      match "elect/:election_id"              => "rsec#elect",            :as => :elect, :via => [:get, :post]
      match "unelect/:election_id"             => "rsec#unelect",         :as => :unelect, :via => [:get, :post]
      match "elections"                       => "rsec#elections",        :as => :elections, :via => [:get, :post]
      match "find_members"                    => "rsec#find_members", :via => [:get, :post]
      get   "election_sheet"                  => "rsec#election_sheet",   :as => :election_sheet
      post  "commit/:election_id"             => "rsec#commit",           :as => :commit
      post  "commit_all"                      => "rsec#commit_all",       :as => :commit_all
    end # rsec

    scope "deprel" do
      match "/" => "deprel#overview", :via => [:get, :post]
    end
    scope "indrel" do
      match "/" => "indrel#indrel_db", :as => "indrel_db", :via => [:get, :post]

    end
    scope "tutor" do
      match "signup_slots" => "tutor#signup_slots", :as=>:tutor_signup_slots, :via => [:get, :post]
      match "signup_courses" => "tutor#signup_courses", :as=>:tutor_signup_courses, :via => [:get, :post]
      post "update_preferences" => "tutor#update_preferences", :as=>:update_course_preferences
      get "edit_schedule" => "tutor#edit_schedule", :as=>:tutor_edit_schedule
      get "upload_schedule" => "tutor#upload_schedule", :as=>:tutor_upload_schedule
      post "json_update" => "tutor#json_update", :as=>:tutor_json_update
      put "update_schedule" => "tutor#update_schedule", :as=>:tutor_update_schedule
      match "params_for_scheduler" => "tutor#params_for_scheduler", :via => [:get, :post]
      match "/" => "tutor#settings", :via => [:get, :post]
      match "settings" => "tutor#settings", :as=>:tutor_settings, :via => [:get, :post]
      match "find_courses" => "tutor#find_courses", :via => [:get, :post]
      match "add_course" => "tutor#add_course", :via => [:get, :post]
      match "update_slots" => "tutor#update_slots", :as => :tutor_update_slots, :via => [:get, :post]
    end

    scope "studrel" do
      match "/" => "studrel#index", :via => [:get, :post]
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
  match "logout" => "user_sessions#destroy", :as => :logout, :via => [:get, :post]
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
    match "list(/:category)" => "people#list", :as => :people_list, :via => [:get, :post]
    match "contact_card"     => "people#contact_card", :as => :contact_card, :via => [:get, :post]
  end
  match "account-settings"   => "people#edit",    :as => :account_settings, :via => [:get, :post]
  match "people/:id/edit"    => "people#edit", :via => [:get, :post]
  match "people/:id/approve" => "people#approve", :as => :approve, :via => [:get, :post]
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
    match "registration" => "alumnis#new", :via => [:get, :post]
    match "newsletter" => "alumnis#newsletter", :via => [:get, :post]
  end

  # Resumes, this is kind of just a prototype test right now
  get "resumes/new"
  scope "resumes" do
    match "status_list" => "resumes#status_list", :as => :resumes_status_list, :via => [:get, :post]
    match "upload" => "resumes#new", :as => :resumes_upload, :via => [:get, :post]
    match "upload_for/:id" => "resumes#upload_for", :as => :resumes_upload_for, :via => [:get, :post]
    match "download/:id" => "resumes#download", :as => :resume_download, :via => [:get, :post]
    post  'include/:id' => "resumes#include", :as => :resumes_include
    post  'exclude/:id' => "resumes#exclude", :as => :resumes_exclude
  end
  resources :resumes
  scope "resume_books" do
    match "download_pdf/:id" => "resume_books#download_pdf", :as => :resume_book_download_pdf, :via => [:get, :post]
    match "download_iso/:id" => "resume_books#download_iso", :as => :resume_book_download_iso, :via => [:get, :post]
    match "missing" => "resume_books#missing", :as => :resume_book_missing, :via => [:get, :post]
  end
  resources :resume_books

  # Course Guides
  scope "courseguides" do
    match "/"                              => "courseguide#index", :as => :courseguide, :via => [:get, :post]
    match "/:dept_abbr/:course_number"     => "courseguide#show", :as => :courseguide_show, :via => [:get, :post]
    get "/:dept_abbr/:course_number/edit"  => "courseguide#edit", :as => :courseguide_edit
    match "/:dept_abbr/:course_number/update" => "courseguide#update", :as => :courseguide_update, :via => [:get, :post, :patch]
  end

  # Course Surveys
  scope "coursesurveys" do
    match "/"                              => "coursesurveys#index",      :as => :coursesurveys, :via => [:get, :post]
    match "course/:dept_abbr"              => "coursesurveys#department", :as => :coursesurveys_department, :via => [:get, :post]
    match "course/:dept_abbr/:course_number" => "coursesurveys#course", :as => :coursesurveys_course, :via => [:get, :post]
    match "course/:dept_abbr/:short_name/:semester(/:section)" => "coursesurveys#klass",      :as => :coursesurveys_klass, :via => [:get, :post]

    get   "instructor/new"                 => "coursesurveys#newinstructor", :as => :coursesurveys_new_instructor
    post  "instructor/new"                 => "coursesurveys#createinstructor", :as => :coursesurveys_create_instructor
    get   "instructor/:id/edit"            => "coursesurveys#editinstructor", :as => :coursesurveys_edit_instructor
    match "instructor/:id/update"          => "coursesurveys#updateinstructor", :as => :coursesurveys_update_instructor, :via => [:get, :post]
    # This is a hack to allow periods in the parameter. Otherwise, Rails automatically splits on periods
    get   "instructor/:name"               => "coursesurveys#instructor", :as => :coursesurveys_instructor, :constraints => {:name => /.+/}
    #match ":category"                      => "coursesurveys#instructors",:as => :coursesurveys_instructors, :constraints => {:category => /(instructors)|(tas)/}
    get   "instructors"                    => "coursesurveys#instructors", :as => :coursesurveys_instructors
    get   "tas"                            => "coursesurveys#tas",         :as => :coursesurveys_tas

    match "rating/:id"                     => "coursesurveys#rating",     :as => :coursesurveys_rating, :via => [:get, :post]
    match "rating/:id/edit"                => "coursesurveys#editrating", :as => :coursesurveys_edit_rating, :via => [:get, :post]
    match "rating/:id/update"              => "coursesurveys#updaterating", :as => :coursesurveys_update_rating, :via => [:get, :post]

    match "search(/:q)"                    => "coursesurveys#search",     :as => :coursesurveys_search, :via => [:get, :post]

    match "how-to"                         => "static#coursesurveys_how_to",     :as => :coursesurveys_how_to, :via => [:get, :post]
    match "info-profs"                     => "coursesurveys#coursesurveys_info_profs", :as => :coursesurveys_info_profs, :via => [:get, :post]
    match "ferpa"                          => "static#coursesurveys_ferpa",      :as => :coursesurveys_ferpa, :via => [:get, :post]

    # Admin stuff
    get   "instructor_ids"                 => "coursesurveys#instructor_ids", :as => :coursesurveys_instructor_ids
    get   "merge_instructors(/:id_0(/:id_1))"              => "coursesurveys#merge_instructors",      :as => :coursesurveys_merge_instructors
    post  "merge_instructors"              => "coursesurveys#merge_instructors_post"
  end

  match "calendar" => "events#calendar", :as => :calendar, :via => [:get, :post]

  scope "events" do
    match "calendar" => "events#calendar", :as => :events_calendar, :via => [:get, :post]
    match "hkn" => "events#hkn", :as => :events_ical, :via => [:get, :post]
    match ":category" => "events#index", :as => :events_category, :constraints => {:category => /(future|past)/}, :via => [:get, :post]

    match "rsvps" => "rsvps#my_rsvps", :as => :my_rsvps, :via => [:get, :post]

    # Routes for RSVP confirmation page
    match "confirm_rsvps/:group" => "events#confirm_rsvps_index", :as => :confirm_rsvps_index, :constraints => {:group => /(candidates|comms)/}, :via => [:get, :post], :via => [:get, :post], :via => [:get, :post], :via => [:get, :post]
    match "confirm_rsvps/:group/event/:id" => "events#confirm_rsvps", :as => :confirm_rsvps, :constraints => {:group => /(candidates|comms)/}, :via => [:get, :post]
    match "confirm/:id" => "rsvps#confirm", :as => :confirm_rsvp, :via => [:get, :post]
    match "unconfirm/:id" => "rsvps#unconfirm", :as => :unconfirm_rsvp, :via => [:get, :post]
    match "reject/:id" => "rsvps#reject", :as => :reject_rsvp, :via => [:get, :post]
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
    match "/"                         => "indrel#index",                          :as => "indrel", :via => [:get, :post]
    match "career-fair"               => "indrel#career_fair",                    :as => "career_fair", :via => [:get, :post]
    match "contact-us"                => "indrel#contact_us",              :as => "indrel_contact_us", :via => [:get, :post]
    match "infosessions"              => "indrel#infosessions",                   :as => "infosessions", :via => [:get, :post]
    get   "infosessions/registration" => "indrel#infosessions_registration",      :as => "infosessions_registration"
    post  "infosessions/registration" => "indrel#infosessions_registration_post", :as => "infosessions_registration_post"
    match "resume-books"              => "indrel#resume_books",                   :as => "resume_books_about", :via => [:get, :post]
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
    match "comingsoon" => "static#comingsoon", :via => [:get, :post]
  end

  # Static pages
  scope "about" do
    match "contact"   => "static#contact", :via => [:get, :post]
    match "comingsoon" => "static#comingsoon", :via => [:get, :post]
    match "yearbook"  => "static#yearbook", :via => [:get, :post]
    match "slideshow" => "static#slideshow", :via => [:get, :post]
    match "officers(/:semester)" => "static#officers", :as => "about_officers", :via => [:get, :post]
    match "cmembers(/:semester)" => "static#cmembers", :as => "about_cmembers", :via => [:get, :post]
  end

  #Tutoring pages
  scope "tutor" do
    match "/" => "tutor#schedule", :as => "tutor", :via => [:get, :post]
    match "schedule" => "tutor#schedule", :via => [:get, :post]
    match "calendar" => "tutor#calendar", :via => [:get, :post]
  end

  # Exams
  scope "exams" do
    match '/'                                     => "exams#index", :via => [:get, :post],
      :as => :exams
    match "search(/:q)"                                => "exams#search",
      :as => :exams_search, :via => [:get, :post]
    match "course/:dept_abbr"                     => "exams#department",
      :as => :exams_department, :via => [:get, :post]
    match "course/:dept_abbr/:full_course_number" => "exams#course",
      :as => :exams_course, :via => [:get, :post]
    match 'course'                                => redirect('/exams'), :via => [:get, :post]
    get 'new'                                     => "exams#new",
      :as => :exams_new
    post 'create'                                 => "exams#create",
      :as => :exams_create
  end
  #resources :exams

  #Candidates
  scope "cand" do
    match "portal" => "candidates#portal", :as => :candidate_portal, :via => [:get, :post]
    match "quiz" => "candidates#quiz", :via => [:get, :post]
    match "application" => "candidates#application", :via => [:get, :post]
    match "submit_quiz" => "candidates#submit_quiz", :via => [:get, :post]
    match "submit_app" => "candidates#submit_app", :via => [:get, :post]
    match "request_challenge" => "candidates#request_challenge", :as => :request_challenge, :via => [:get, :post]
    match "update_challenges" => "candidates#update_challenges", :as => :update_challenges, :via => [:get, :post]
    match "find_officers" => "candidates#find_officers", :as => :find_officers, :via => [:get, :post]
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

  match "factorial/:x" => "home#factorial", :via => [:get, :post]

end
