Rails.application.routes.draw do
  resources :posts do
    member do
      post :publish
      post :unpublish
      post :toggle_featured
      post :archive
    end
    resources :comments, only: %i[create destroy]
  end

  resources :users
  root "posts#index"
end
