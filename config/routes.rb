Rails.application.routes.draw do
  resources :service_orders do
    # Cada ordem tem no máximo um diagnóstico (recurso singular aninhado).
    resource :diagnostic, only: %i[ new create edit update ]
  end
  resource :session
  resources :passwords, param: :token
  resources :service_categories
  resources :customers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Temporário: na Fase 12 (dashboard) isto vira root "dashboard#index".
  root "customers#index"
end
