Rails.application.routes.draw do
  get "tests/index"
  get "tests/show"
  # Health check route: returns 200 if the app boots with no exceptions.
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication.
  devise_for :users

  # Active Admin routes for the admin panel.
  ActiveAdmin.routes(self)

  # Routes for Course products.
  resources :courses

  # Routes for Test products.
  resources :tests, only: [:index, :show]

  # Test side: routes for test-taking functionality.
  namespace :tests do
    resources :test_attempts, only: [:index, :new, :create, :edit, :update, :show]
  end

  # Root path route.
  root to: "home#index"
end
