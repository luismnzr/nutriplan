Rails.application.routes.draw do
  devise_for :users

  resource :today, only: :show, controller: "today"

  resources :plans do
    resources :meals, only: [:create]
    get :shopping_list, on: :member
  end
  resources :meals, only: [:destroy] do
    resources :meal_items, only: [:create]
    resource :meal_log, only: :create, controller: "meal_logs"
  end
  resources :meal_items, only: [:update, :destroy]
  resources :plan_days, only: [] do
    resource :daily_note, only: :create, controller: "daily_notes"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"
end
