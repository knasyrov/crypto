Rails.application.routes.draw do
  resources :transactions, except: [ :edit, :destroy ]
  resources :admin, only: :index
  resources :addresses, only: :index

  root "home#index"
end
