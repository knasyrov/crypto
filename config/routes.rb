Rails.application.routes.draw do
  resources :transactions
  resources :admin, only: :index
  resources :addresses, only: [:index, :show]

  root "home#index"
end
