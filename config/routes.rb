Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication.
  devise_for :users
  
  # Manual sign out route
  delete '/users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session

  # Custom Admin Panel routes
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :courses
    resources :tests
    resources :questions
  end

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
