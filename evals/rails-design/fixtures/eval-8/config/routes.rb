Rails.application.routes.draw do
  resources :orders, only: %i[new create show] do
    member do
      post :confirm
    end
  end

  resources :products, only: %i[index show]
  root "products#index"
end
