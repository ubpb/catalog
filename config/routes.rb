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
    resources :hold_requests, only: [:index], path: "hold-requests"
  end

end
