Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication.
  devise_for :users

  # Custom Admin Panel routes
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :courses
    resources :tests
    resources :questions
  end

  # Courses routes
  get 'courses/browse', to: 'courses#browse', as: :browse_courses
  resources :courses

  # Test side: test-taking functionality.
  namespace :tests do
    resources :test_attempts, only: [:index, :new, :create, :edit, :update, :show]
  end

  # Routes for Test products (available tests).
  resources :tests, only: [:index, :show], constraints: { id: /\d+/ }

  # Payment routes
  resources :payments, only: [:index, :show, :new, :create] do
    member do
      post :confirm
    end
  end
  
  # Payment success and cancel routes
  get 'payments/success', to: 'payments#success', as: :payment_success
  get 'payments/cancel', to: 'payments#cancel', as: :payment_cancel

  # Stripe webhooks
  post 'webhooks/stripe', to: 'webhooks#stripe'

  # Root path route.
  root to: "home#index"
  
  # Favicon route
  get '/favicon.ico', to: proc { [204, {}, []] }
end
