Rails.application.routes.draw do
  resources :transactions
  resources :admin, only: :index

  root "home#index"
end
