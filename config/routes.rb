Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication.
  devise_for :users

  # Active Admin routes for the admin panel.
  ActiveAdmin.routes(self)

  # Courses routes
  resources :courses

  # Test side: test-taking functionality.
  namespace :tests do
    resources :test_attempts, only: [:index, :new, :create, :edit, :update, :show]
  end

  # Routes for Test products (available tests).
  resources :tests, only: [:index, :show], constraints: { id: /\d+/ }

  # Root path route.
  root to: "home#index"
  
  # Favicon route
  get '/favicon.ico', to: proc { [204, {}, []] }
end
