Rails.application.routes.draw do
  get "courses/index"
  get "courses/show"
  get "courses/new"
  get "courses/edit"
  namespace :tests do
    get "assessments/new"
    get "assessments/show"
  end
  get "home/index"
  # Health check route: returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for user authentication
  devise_for :users

  resources :courses


  # Active Admin routes for the admin panel
  ActiveAdmin.routes(self)

  # Test side: routes for assessment (test-taking) functionality
  scope module: 'tests' do
    resources :assessments, only: [:index, :new, :create, :edit, :update, :show]
  end

  # Uncomment if you use dynamic PWA files:
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path route
  root to: "home#index"
end
