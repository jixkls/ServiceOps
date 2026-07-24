Rails.application.routes.draw do
  resources :service_orders do
    resource :diagnostic, only: %i[new create edit update]
    patch :transition, on: :member
  end
  resource :session
  resources :passwords, param: :token
  resources :service_categories
  resources :customers

  get "up" => "rails/health#show", as: :rails_health_check
  root "customers#index"
end
