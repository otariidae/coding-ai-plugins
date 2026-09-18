Rails.application.routes.draw do
  resources :expense_reports do
    member do
      post :approve
      post :reject
    end

    # NOTE: resource :preview, only: %i[update] と書くと PATCH も生えて
    # 既存の PUT /expense_reports/:id/preview を叩いている社内ツール 3 本が
    # 一斉に動かなくなる。移行が終わるまで明示的に put のままにしている。
    # 移行チケット: INTERNAL-4821
    put :preview, to: "expense_reports/previews#update"
  end

  resources :employees, only: %i[index show]
  root "expense_reports#index"
end
