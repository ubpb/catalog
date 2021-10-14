Rails.application.routes.draw do

  # Homepage
  root to: "homepage#show"

  # Authentication
  post "/login",  to: "sessions#create", as: :session
  get  "/login",  to: "sessions#new", as: :new_session
  get  "/logout", to: "sessions#destroy", as: :logout

  # Library account
  namespace :account, path: "account" do
    root to: redirect("/account/loans")
    resources :loans, only: [:index] do
      post :renew, on: :member
      post :renew_all, on: :collection, path: "renew"
    end
    resources :fees, only: [:index]
    resources :hold_requests, only: [:index, :destroy], path: "hold-requests"
  end

  # Searches
  get  "/:search_scope/s", to: "searches#index", as: :searches
  post "/:search_scope/s", to: "searches#create"

  # Records
  get "/:search_scope/r/:id", to: "records#show", as: :record

  # Items
  get "/:search_scope/r/:record_id/items", to: "items#index", as: :items

  # Availability
  get "/availabilities(/:mode)", to: "availabilities#index", as: :availabilities

  # Kickers
  get "/go/impressum", to: redirect("http://www.ub.uni-paderborn.de/ueber-uns/impressum/"), as: :legal
  get "/go/datenschutz", to: redirect("https://www.ub.uni-paderborn.de/fileadmin/ub/Dokumente_Formulare/DSE_UB_007_Katalog.pdf"), as: :privacy

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

end
