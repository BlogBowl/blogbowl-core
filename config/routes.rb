require 'sidekiq/web'

Rails.application.routes.draw do

  mount Sidekiq::Web => "/sidekiq"

  constraints host: [Rails.application.routes.default_url_options[:host], ENV.fetch('APP_DOCKER_HOST', 'app')] do
    get 'preview/:share_id', to: 'previews#show', as: :preview

    get "sign_in", to: "sessions#new"
    post "sign_in", to: "sessions#create"
    resources :sessions, only: [:index, :show, :destroy]

    resources :users do
      patch :dismiss_notice, on: :member
    end

    namespace :sessions do
      resource :sudo, only: [:new, :create]
    end

    resources :authors do
      scope module: :authors do
        resources :author_links, path: "links"
      end
      member do
        put :deactivate
      end
    end

    resources :members

    resources :analytics, only: [:index]

    resources :pages, only: [:index, :show, :new, :create]
    namespace :pages do
      scope ':page_id' do

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

    resources :newsletters, only: [:index, :show, :new, :create]
    namespace :newsletters do
      scope ':newsletter_id' do
        resources :newsletter_emails

        resources :subscribers, only: [:index]

        resource :settings, only: [:show]
        namespace :settings do
          namespace :newsletter do
            resource :domain, only: [:edit, :update], controller: :domain do
              put :verify_dkim
              put :verify_return_path
            end
          end
          resource :general, only: [:edit, :update], controller: :general
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
          scope ':page_id' do
            resources :categories, only: [:index, :create]
            resources :posts, only: [:create, :show, :update] do
              post 'publish', to: 'posts#publish'
              delete 'images', to: 'images#destroy', as: :delete_images
              resources :images, only: [:create]
              resources :revisions, only: [:index, :create], controller: 'post_revisions' do
                get 'last', on: :collection, to: 'post_revisions#show_last'
                patch 'last', on: :collection, to: 'post_revisions#update_last'
                post 'last/apply', on: :collection, to: 'post_revisions#apply_last'
                post 'last/share', on: :collection, to: 'post_revisions#share_last'
              end
            end
          end
        end

        resources :authors, only: [:index]

        namespace :newsletters, only: [] do
          scope ':newsletter_id' do
            resources :emails, only: [:create, :show, :update] do
              post 'images', to: "emails#create_image"
              post 'send', to: "emails#send_email"
              post 'send/test', to: "emails#send_test_email"
              post 'unschedule', to: "emails#unschedule_email"
            end
          end
        end
      end
      namespace :public do
        post 'postmark/event', to: 'postmark#on_postmark_event'
      end
    end

    root "home#index"
    get "up" => "rails/health#show", as: :rails_health_check
  end

  # routes for infrastructure
  constraints host: Rails.env.production? ?
                      ENV.fetch('APP_DOCKER_HOST', 'app') :
                      Rails.application.routes.default_url_options[:host] do
                        namespace :api do
                          namespace :internal do
                            get 'domain/verify', to: 'domains#verify'
                            get 'analytics/user', to: 'analytics#show_user'
                          end
                        end
                      end

  constraints(PublicRouteConstraint) do
    scope module: 'public' do
      # Add robots.txt route
      get 'robots.txt', to: 'pages#robots', as: :robots
      get "sitemap.xml", to: "sitemap#index", as: :public_sitemap

      post 'subscribe', to: 'subscriber#create', as: :public_subscribe
      get 'subscribe/verify/:token', to: 'subscriber#verify', as: :public_subscribe_verify

      get "/", to: "pages#show", as: :public_root
      get "posts/:id", to: "posts#show", as: :public_post

      # TODO: Configure layout templates
      # paginated authors
      get "authors", to: "authors#index", as: :public_authors
      get "authors/page/1", to: redirect('/authors')
      get "authors/page/:page", to: "authors#index", as: 'public_authors_page'

      # paginated author
      get "authors/:id", to: "authors#show", as: :public_author
      get "authors/:id/page/1", to: redirect('/authors/%{id}')
      get "authors/:id/page/:page", to: "authors#show", as: 'public_author_page'

      # paginated all categories
      get "categories", to: "categories#index", as: :public_categories
      get "categories/page/1", to: redirect('/categories')
      get "categories/page/:page", to: "categories#index", as: 'public_categories_page'

      # paginated categories
      get "categories/:id", to: "categories#show", as: :public_category
      get "categories/:id/page/1", to: redirect('/category/%{id}')
      get "categories/:id/page/:page", to: "categories#show", as: 'public_category_page'

      # paginated archive
      get 'archive', to: 'archive#show', as: :public_archive
      get 'archive/page/1', to: redirect('/archive')
      get 'archive/page/:page', to: 'archive#show', as: 'public_archive_page'
    end
  end
end

Rails.application.routes.append do
  constraints host: Rails.application.routes.default_url_options[:host] do
    match '*path', to: "pages#render_not_found", via: :get
  end

  constraints(PublicRouteConstraint) do
    scope module: 'public' do
      match '*path', to: "pages#render_not_found", via: :get
    end
  end
end
