Rails.application.routes.draw do
  get 'oauths/oauth'
  get 'oauths/callback'
  root "static_pages#top"
  resources :summaries, only: %i[new create index show edit update destroy]
  # 今回はgoogleログインのみに限定
  # resources :users, only: %i[new create]
  # get 'login', to: 'user_sessions#new'
  # post 'login', to: 'user_sessions#create'

  resources :voices, only: %i[new create index show edit update destroy]
  delete 'logout', to: 'user_sessions#destroy'

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback"
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
end
