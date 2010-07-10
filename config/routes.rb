HknRails::Application.routes.draw do |map|
  get "tutor_admin/index"

  get "tutor_admin/signup_slots"

  get "tutor_admin/signup_classes"

  get "tutor_admin/generate_schedule"

  get "tutor_admin/view_signups"

  get "tutor_admin/edit_schedule"

  get "tutor_admin/settings"


  get "home/index"

  root :to => "home#index"

  # Login
  match "login" => "user_sessions#new"
  match "create_session" => "user_sessions#create"
  match "logout" => "user_sessions#destroy"

  resources :events
  resources :properties

  # Indrel site
  scope "indrel" do
    match "" => "static#indrel"
    match "career-fair" => "static#career_fair", :as => "career_fair"
    scope "db" do
      match "" => "static#indrel_db"
      resources :companies
      resources :contacts
      resources :events,      :controller => "indrel_events",      :as => "indrel_events"
      resources :event_types, :controller => "indrel_event_types", :as => "indrel_event_types"
      resources :locations
    end
  end

  # Static pages
  scope "about" do
    match "contact"   => "static#contact"
    match "yearbook"  => "static#yearbook"
    match "slideshow" => "static#slideshow"
  end

  #resources :user_session

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
