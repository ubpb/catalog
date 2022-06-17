Rails.application.routes.draw do

  # Homepage
  root to: "homepage#show"

  # Authentication
  post "/login",  to: "sessions#create", as: :session
  get  "/login",  to: "sessions#new", as: :new_session
  get  "/logout", to: "sessions#destroy", as: :logout

  # Password reset
  get  "/password/reset",        to: "password_resets#new",    as: :password_reset_request
  post "/password/reset",        to: "password_resets#create", as: nil
  get  "/password/reset/:token", to: "password_resets#edit",   as: :password_reset
  put  "/password/reset/:token", to: "password_resets#update", as: nil

  # Library account
  namespace :account, path: "account" do
    root to: redirect("/account/loans")
    resources :loans, only: [:index] do
      post :renew, on: :member
      post :renew_all, on: :collection, path: "renew"
    end
    resources :fees, only: [:index]
    resources :hold_requests, only: [:index, :destroy], path: "hold-requests"
    resources :watch_lists, path: "watch-lists" do
      resources :watch_list_entries, path: "entries", as: "entries", only: [:destroy]
    end
  end

  # Closed stack orders
  resources :closed_stack_orders, only: [:new, :create], path: "cso"

  # Dedicated controllers for view components
  scope "watch-lists-panel-component" do
    post "create-watch-list/:search_scope/:record_id", to: "watch_lists_panel_component#create_watch_list", as: :watch_lists_panel_component_create_watch_list
    put  "add-record/:watch_list_id/:search_scope/:record_id", to: "watch_lists_panel_component#add_record", as: :watch_lists_panel_component_add_record
    put  "remove-record/:watch_list_id/:search_scope/:record_id", to: "watch_lists_panel_component#remove_record", as: :watch_lists_panel_component_remove_record
  end

  # Searches
  get  "/:search_scope/s", to: "searches#index", as: :searches
  post "/:search_scope/s", to: "searches#create"

  # Records / Items / Hold requests / Relations
  resources :records, path: "/:search_scope/r", only: [:show] do
    resources :items, only: [:index]
    resources :hold_requests, path: "hold-requests", only: [:create, :destroy]
    resources :relations, only: [:index]
  end

  # Availability
  get "/availabilities(/:mode)", to: "availabilities#index", as: :availabilities

  # Open URL Link-Resolver
  get "openurl", to: "link_resolver#show"

  # Cover images
  get "cover-images/:id", to: "cover_images#show", as: "cover_image"

  # Kickers
  get "/go/impressum", to: redirect("http://www.ub.uni-paderborn.de/ueber-uns/impressum/"), as: :legal
  get "/go/datenschutz", to: redirect("https://www.ub.uni-paderborn.de/fileadmin/ub/Dokumente_Formulare/DSE_UB_007_Katalog.pdf"), as: :privacy

  # Permalinks
  get "/p/:id", to: "permalinks#resolve", as: :resolve_permalink
  resources :permalinks, only: [:create, :show]

  # Compatability for records and searches of older versions
  # Version 1.x records
  get "/records/:id", to: "compat/v1_records#show", constraints: { id: /.+/ }
  get "/searches/:search_id/records/:id", to: "compat/v1_records#show", constraints: { id: /.+/ }
  # Version 1.x searches
  get "/searches", to: "compat/v1_searches#index"
  get "/searches/:hashed_id", to: "compat/v1_searches#show"
  # Version 2.x records
  get "/:search_scope/records/:id", to: "compat/v2_records#show", constraints: { id: /.+/ }
  # Version 2.x searches
  get "/:search_scope/searches", to: "compat/v2_searches#index"

  # Dev Tools
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end
