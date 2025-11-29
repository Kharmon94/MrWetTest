Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication.
  devise_for :users

  # Custom Admin Panel routes
  namespace :admin do
    root to: 'dashboard#index'
    resources :users do
      member do
        post :impersonate
        post :send_reset_password
      end
    end
    resources :courses
    resources :lessons
    resources :tests
    resources :questions
    resources :test_attempts
  end


  # Courses routes
  get 'courses/browse', to: 'courses#browse', as: :browse_courses
  resources :courses do
    resources :lessons, only: [:index, :show]
    resources :tests, only: [:index, :show], controller: 'courses/tests'
  end

  # Test side: test-taking functionality.
  namespace :tests do
    resources :test_attempts, only: [:index, :new, :create, :edit, :update, :show] do
      member do
        post :abandon
      end
    end
  end

  # Assessment compliance routes for course tests
  resources :tests, only: [], constraints: { id: /\d+/ } do
    # Assessment compliance routes
    member do
      get :procedures, to: 'assessment_compliance#show_procedures'
      get :honor_statement, to: 'assessment_compliance#show_honor_statement'
      post :accept_honor, to: 'assessment_compliance#accept_honor_statement'
      get :security_policies, to: 'assessment_compliance#security_policies'
    end
  end

  # Payment success and cancel routes (must come before resources)
  get 'payments/success', to: 'payments#success', as: :payment_success
  get 'payments/cancel', to: 'payments#cancel', as: :payment_cancel
  
  # Payment routes
  resources :payments, only: [:index, :show, :new, :create] do
    member do
      post :confirm
    end
  end

  # Stripe webhooks
  post 'webhooks/stripe', to: 'webhooks#stripe'

  # Settings routes
  scope '/settings' do
    root to: 'settings#index', as: 'settings_root'
    get 'profile', to: 'settings#profile', as: 'settings_profile'
    patch 'profile', to: 'settings#update_profile'
    get 'preferences', to: 'settings#preferences', as: 'settings_preferences'
    patch 'preferences', to: 'settings#update_preferences'
    get 'security', to: 'settings#security', as: 'settings_security'
    patch 'security', to: 'settings#update_password'
    get 'notifications', to: 'settings#notifications', as: 'settings_notifications'
    patch 'notifications', to: 'settings#update_notifications'
    get 'account', to: 'settings#account', as: 'settings_account'
    post 'export_data', to: 'settings#export_data', as: 'settings_export_data'
    delete 'delete_account', to: 'settings#delete_account', as: 'settings_delete_account'
  end

  # Root path route.
  root to: "home#index"
  
  # Favicon route
  get '/favicon.ico', to: proc { [204, {}, []] }
end
