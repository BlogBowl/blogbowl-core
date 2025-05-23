Rails.application.routes.draw do
  constraints host: Rails.application.routes.default_url_options[:host] do
    get "sign-in", to: "sessions#new", as: :new_session
    post "sign-in", to: "sessions#create", as: :session
    resource :session, only: [:destroy]

    root "home#index"

    resources :authors do
      scope module: :authors do
        resources :author_links, path: "links"
      end
      member do
        put :deactivate
      end
    end

    resources :members
    resources :workspaces, only: [:index, :show, :create]

    resources :pages, only: [:index, :show, :new, :create]
    namespace :pages do
      scope ":page_id" do

        resources :posts do
          member do
            post :publish
            post :draft
          end
        end
        resources :categories

        resources :analytics, only: [:index]

        resource :settings, only: [:show]
        namespace :settings do
          resource :general, only: [:edit, :update], controller: :general
          resource :header, only: [:edit, :update], controller: :header
          resource :footer, only: [:edit, :update], controller: :footer
          resource :code, only: [:edit, :update], controller: :code
          resource :layout, only: [:edit, :update], controller: :layout
          resource :cta, only: [:edit, :update], controller: :cta
          resource :domain, only: [:edit, :update], controller: :domain
          resources :links, only: [:new, :create, :edit, :update, :destroy]
          resource :newsletter, only: [:edit, :update], controller: :newsletter
        end
      end
    end

    resource :settings, only: [:show]
    namespace :settings do
      resource :general, only: [:edit, :update], controller: :general
    end

    namespace :api do
      namespace :internal do
        namespace :pages, only: [] do
          scope ":page_id" do
            resources :categories, only: [:index, :create]
            resources :posts, only: [:create, :show, :update] do
              post "publish", to: "posts#publish"
              delete "images", to: "images#destroy", as: :delete_images
              resources :images, only: [:create]
              resources :revisions, only: [:index, :create], controller: "post_revisions" do
                get "last", on: :collection, to: "post_revisions#show_last"
                patch "last", on: :collection, to: "post_revisions#update_last"
                post "last/apply", on: :collection, to: "post_revisions#apply_last"
                post "last/share", on: :collection, to: "post_revisions#share_last"
              end
            end
          end
        end

        resources :authors, only: [:index]
      end
    end
  end

  constraints(PublicRouteConstraint) do
    scope module: "public" do
      # Add robots.txt route
      get "robots.txt", to: "pages#robots", as: :robots

      post "subscribe", to: "subscriber#create", as: :public_subscribe
      get "subscribe/verify/:token", to: "subscriber#verify", as: :public_subscribe_verify

      get "/", to: "pages#show", as: :public_root
      get "posts/:id", to: "posts#show", as: :public_post

      # TODO: Configure layout templates
      # paginated authors
      get "authors", to: "authors#index", as: :public_authors
      get "authors/page/1", to: redirect("/authors")
      get "authors/page/:page", to: "authors#index", as: "public_authors_page"

      # paginated author
      get "authors/:id", to: "authors#show", as: :public_author
      get "authors/:id/page/1", to: redirect("/authors/%{id}")
      get "authors/:id/page/:page", to: "authors#show", as: "public_author_page"

      # paginated all categories
      get "categories", to: "categories#index", as: :public_categories
      get "categories/page/1", to: redirect("/categories")
      get "categories/page/:page", to: "categories#index", as: "public_categories_page"

      # paginated categories
      get "categories/:id", to: "categories#show", as: :public_category
      get "categories/:id/page/1", to: redirect("/category/%{id}")
      get "categories/:id/page/:page", to: "categories#show", as: "public_category_page"

      # paginated archive
      get "archive", to: "archive#show", as: :public_archive
      get "archive/page/1", to: redirect("/archive")
      get "archive/page/:page", to: "archive#show", as: "public_archive_page"
    end
  end
end

Rails.application.routes.append do
  constraints host: Rails.application.routes.default_url_options[:host] do
    match "*path", to: "pages#render_not_found", via: :get
  end

  constraints(PublicRouteConstraint) do
    scope module: "public" do
      match "*path", to: "pages#render_not_found", via: :get
    end
  end
end
