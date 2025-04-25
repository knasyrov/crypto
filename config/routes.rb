Rails.application.routes.draw do
  resources :transactions, except: [ :edit, :destroy ] do
    member do
      get :send_tr
    end
  end
  resources :admin, only: :index
  resources :addresses, only: :index do
    collection do
      get :reload
    end
  end

  root "home#index"
end
