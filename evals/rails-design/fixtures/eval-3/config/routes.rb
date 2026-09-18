Rails.application.routes.draw do
  namespace :api do
    resources :playlists do
      member do
        post :publish
      end
    end
  end
end
