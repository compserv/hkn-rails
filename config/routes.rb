HknRails::Application.routes.draw do

  match "test_exception_notification" => "application#test_exception_notification"

  #Department tours
  scope "dept_tour" do
    match "/" => "dept_tour#signup", :as => :dept_tour_signup
    match "success" => "dept_tour#success"
  end
  
  namespace :admin do
    scope "general", :as => "general" do
      match "confirm_challenges" => "admin#confirm_challenges"
      match "confirm_challenge/:id" => "admin#confirm_challenge"
      match "reject_challenge/:id" => "admin#reject_challenge"
      match "candidate_announcements" => "admin#candidate_announcements"
      match "create_announcement" => "admin#create_announcement"
      match "edit_announcement/:id" => "admin#edit_announcement"
      match "update_announcement" => "admin#update_announcement"
      match "delete_announcement/:id" => "admin#delete_announcement"
    end

    scope "eligibilities" do
      get   "/"         => "eligibilities#list",      :as => :eligibilities
      post  "update"    => "eligibilities#update",    :as => :update_eligibilities
      post  "upload"    => "eligibilities#upload",    :as => :upload_eligibilities
      post  "reprocess" => "eligibilities#reprocess", :as => :reprocess_eligibilities
      get   "candidates.csv" => "eligibilities#csv",       :as => :eligibilities_csv
    end
    
    scope "csec", :as => "csec" do
      match "/" => "csec#index"
      get "select_classes" => "csec#select_classes", :as => :select_classes
      post "select_classes" => "csec#select_classes_post", :as => :select_classes_post
      get "manage_classes" => "csec#manage_classes", :as => :manage_classes
      post "manage_classes" => "csec#manage_classes_post", :as => :manage_classes_post
      match "manage_candidates" => "csec#manage_candidates", :as => :manage_candidates

      get  "upload_surveys" => "csec#upload_surveys",  :as => :upload_surveys
      post "upload_surveys" => "csec#upload_surveys_post", :as => :upload_surveys_post
    end
    scope "deprel" do
      match "/" => "deprel#overview"
    end
    scope "indrel" do
      match "/" => "indrel#indrel_db", :as => "indrel_db"

    end
    scope "tutor" do
      match "signup_slots" => "tutor#signup_slots", :as=>:tutor_signup_slots
      match "signup_courses" => "tutor#signup_courses", :as=>:tutor_signup_courses
      match "edit_schedule" => "tutor#edit_schedule", :as=>:tutor_edit_schedule
      match "params_for_scheduler" => "tutor#params_for_scheduler"
      match "/" => "tutor#settings"
      match "settings" => "tutor#settings", :as=>:tutor_settings
      match "find_courses" => "tutor#find_courses"
      match "add_course" => "tutor#add_course"
      match "update_slots" => "tutor#update_slots"
    end
  end
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
  match "login" => "user_sessions#new"
  match "create_session" => "user_sessions#create"
  match "logout" => "user_sessions#destroy"

  # Registration
  get  "register" => "people#new"
  post "register" => "people#create"

  # People
  scope "people" do
    match "list(/:category)" => "people#list", :as => :people_list
  end
  match "account-settings"   => "people#edit",    :as => :account_settings
  match "people/:id/edit"    => "people#edit"
  match "people/:id/approve" => "people#approve", :as => :approve
  get   "people/:login"      => "people#show",    :as => :profile, :constraints => {:login => /.+/}
  resources :people, :except => [:new, :create, :index]

  match "leaderboard" => "leaderboard#index", :as => :leaderboard

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
  end
  resources :resumes
  scope "resume_books" do
    match "download_pdf/:id" => "resume_books#download_pdf", :as => :resume_book_download_pdf
    match "download_iso/:id" => "resume_books#download_iso", :as => :resume_book_download_iso
    match "missing" => "resume_books#missing", :as => :resume_book_missing
  end
  resources :resume_books

  # Course Surveys
  scope "coursesurveys" do
    match "/"                                       => "coursesurveys#index",      :as => :coursesurveys
    match "course/:dept_abbr"                       => "coursesurveys#department", :as => :coursesurveys_department
    match "course/:dept_abbr/:short_name"           => "coursesurveys#course",     :as => :coursesurveys_course
    match "course/:dept_abbr/:short_name/:semester(/:section)" => "coursesurveys#klass",      :as => :coursesurveys_klass
    # This is a hack to allow periods in the parameter. Otherwise, Rails automatically splits on periods
    get "instructor/:id/edit"                     => "coursesurveys#editinstructor", :as => :coursesurveys_edit_instructor
    match "instructor/:id/update"                     => "coursesurveys#updateinstructor", :as => :coursesurveys_update_instructor
     get "instructor/:name"                        => "coursesurveys#instructor", :as => :coursesurveys_instructor, :constraints => {:name => /.+/}
   match "rating/:id"                              => "coursesurveys#rating",     :as => :coursesurveys_rating
    match "rating/:id/edit"                         => "coursesurveys#editrating", :as => :coursesurveys_edit_rating
    match "rating/:id/update"                       => "coursesurveys#updaterating", :as => :coursesurveys_update_rating
    match "search(/:q)"                         => "coursesurveys#search",     :as => :coursesurveys_search
    match ":category"                               => "coursesurveys#instructors",:as => :coursesurveys_instructors, :constraints => {:category => /(instructors)|(tas)/}
    
    match "how-to"                                  => "static#coursesurveys_how_to",     :as => :coursesurveys_how_to
    match "info-profs"                              => "coursesurveys#coursesurveys_info_profs", :as => :coursesurveys_info_profs
    match "ferpa"                                   => "static#coursesurveys_ferpa",      :as => :coursesurveys_ferpa
  end

  
  scope "events" do
    match "calendar" => "events#calendar", :as => :events_calendar
    match "hkn" => "events#hkn", :as => :events_ical
    match ":category" => "events#index", :as => :events_category, :constraints => {:category => /(future|past)/}

    match "rsvps" => "rsvps#my_rsvps", :as => :my_rsvps

    #Routes for vp's rsvp confirmation page
    match "confirm_rsvps" => "events#vp_confirm", :as => :vp_confirm
    match "confirm_rsvps/event/:id" => "events#rsvps_confirm", :as => :confirm_event_rsvps
    match "confirm/:id" => "rsvps#confirm", :as => :confirm_rsvp
    match "unconfirm/:id" => "rsvps#unconfirm", :as => :unconfirm_rsvp
    match "reject/:id" => "rsvps#reject", :as => :reject_rsvp
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
    resources :companies
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
    match "officers" => "static#officers"
  end

  #Tutoring pages
  scope "tutor" do
    match "/" => "tutor#schedule", :as => "tutor"
    match "schedule" => "tutor#schedule"
  end
  
  # Exams
  scope "exams" do
    match '/'                                     => "exams#index",
      :as => :exams
    match "search(?q=:q)"                                => "exams#search",
      :as => :exams_search
    match "course/:dept_abbr"                     => "exams#department",
      :as => :exams_department
    match "course/:dept_abbr/:full_course_number" => "exams#course",
      :as => :exams_course
    match 'course'                                => redirect('/exams')
  end
  #resources :exams

  #Candidates
  scope "cand" do
    match "portal" => "candidates#portal", :as => :candidate_portal
    match "quiz" => "candidates#quiz"
    match "application" => "candidates#application"
    match "submit_quiz" => "candidates#submit_quiz"
    match "submit_app" => "candidates#submit_app"
    match "request_challenge" => "candidates#request_challenge"
    match "update_challenges" => "candidates#update_challenges"
    match "find_officers" => "candidates#find_officers"
    get "coursesurvey_signup" => "candidates#coursesurvey_signup", :as => "coursesurvey_signup"
    post "coursesurvey_signup" => "candidates#coursesurvey_signup_post", :as => "coursesurvey_signup_post"
  end
  #resources :user_session

  match "factorial/:x" => "home#factorial"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
