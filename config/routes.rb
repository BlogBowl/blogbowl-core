Rails.application.routes.draw do
  constraints host: Rails.application.routes.default_url_options[:host] do
    get "sign-in", to: "sessions#new", as: :new_session
    post "sign-in", to: "sessions#create", as: :session
    resource :session, only: [:destroy]
  end
end
