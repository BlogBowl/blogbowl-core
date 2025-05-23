Rails.application.routes.draw do
  get "sign-in", to: "sessions#new", as: :new_session
  post "sign-in", to: "sessions#create", as: :session
  resource :session, only: [ :destroy ]

  root "home#index"
end
