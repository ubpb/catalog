Rails.application.routes.draw do
  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

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

  # Account activation (public route to start the process without login)
  get   "/activation",         to: "activations#show",   as: :activation_root
  get   "/activation/request", to: "activations#new",    as: :request_activation
  post  "/activation/request", to: "activations#create", as: nil
  get   "/activation/:token",  to: "activations#edit",   as: :activation
  match "/activation/:token",  to: "activations#update", via: [:put, :patch]

  # Locale switching
  get "/locale/:locale", to: "locales#switch", as: :locale

  # User registration for external users
  resources :registration_requests,
    only: [:new, :create],
    path: "registration",
    path_names: {new: "new/:user_group"}

  resources :registrations,
    except: [:destroy],
    path_names: {new: "new/:token"} do
    match "authorize", via: [:get, :post], on: :member
  end

  # Admin routes (for now, just for registrations and activations)
  namespace :admin do
    root to: redirect("/admin/registrations")

    resource :session, only: [:new, :create, :destroy]

    resource :global_message, path: "global-message"

    resources :registrations do
      get :confirm, on: :member
      get :check_duplicates, on: :member, path: "check-duplicates"
      get :print, on: :member
    end

    resources :activations, only: [:index, :new, :create] do
      get "print/user/:user_id", on: :collection, as: :print, action: :print
    end
  end

  # Library account
  namespace :account, path: "account" do
    root to: redirect("/account/loans")
    resources :loans, only: [:index] do
      post :renew, on: :member
      post :renew_all, on: :collection, path: "renew"
    end
    resources :loans_history, only: [:index], path: "loans-history"
    resources :fees, only: [:index]
    resources :hold_requests, only: [:index, :destroy], path: "hold-requests"
    resources :inter_library_loans, only: [:index], path: "ill"
    resources :watch_lists, path: "watch-lists" do
      resources :watch_list_entries, path: "entries", as: "entries", only: [:destroy]
    end
    resources :notes, only: [:index, :create, :update, :destroy], path: "notes"
    resources :calendar, only: [:index]
    resource :profile, only: [:show]
    resource :password, only: [:edit, :update]
    resource :email, only: [:edit, :update]
    resource :id_card, only: [:show], path: "id-card" do
      match "authorize", via: [:get, :post], on: :member
    end
    resource :pin, except: [:destroy]
    resources :proxy_users, path: "proxy-users", except: [:show]
    resources :todos, only: [:index]
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

  # Records / Items / Hold requests / Relations / ...
  resources :records, path: "/:search_scope/r", only: [:show] do
    resources :items, only: [:index] do
      get "semapp-location", on: :member
    end
    resources :hold_requests, path: "hold-requests", only: [:create, :destroy]
    resources :relations, only: [:index]
    resources :volumes, only: [:index]
    resources :recommendations, only: [:index]
    resources :fulltexts, only: [:index]
    resources :cover_images, only: [:index], path: "cover"
  end

  # Open URL Link-Resolver
  get "openurl", to: "link_resolver#show"

  # ZDB Journal, Online & Print Service
  get "joap", to: "joap#show", as: "joap"

  # Lobid Gnd API
  get "gnd/:id", to: "gnd#show", as: "gnd"

  # Kickers and static redirectd
  get "/go/impressum", to: redirect("http://www.ub.uni-paderborn.de/ueber-uns/impressum/"), as: :go_legal
  get "/go/datenschutz", to: redirect("https://www.ub.uni-paderborn.de/fileadmin/ub/Dokumente_Formulare/DSE_UB_007_Katalog.pdf"), as: :go_privacy
  get "/go/ill", to: redirect("https://ub-paderborn.digibib.net/"), as: :go_ill
  get "/go/ill-info", to: redirect("https://www.ub.uni-paderborn.de/nutzen-und-leihen/fernleihe/"), as: :go_ill_info
  get "/go/item-call-number-info", to: redirect("http://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-systemstellen/"), as: :go_item_call_number_info
  get "/go/journal-call-number-info", to: redirect("http://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-fachkennziffern/"), as: :go_journal_call_number_info
  get "/fachsystematik", to: redirect("https://data.ub.uni-paderborn.de/fachsystematik/")
  get "/fachsystematik/*path", to: redirect("https://data.ub.uni-paderborn.de/fachsystematik/%{path}")

  # Permalinks
  get "/p/:id", to: "permalinks#resolve", as: :resolve_permalink
  resources :permalinks, only: [:create, :show]

  # API
  namespace :api do
    namespace :v1 do
      get "user/calendar" => "calendar#show"
    end
  end

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

  # More compatability
  get "/user", to: redirect("/account")
  get "/user/*other", to: redirect("/account")

  # Dev Tools
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
