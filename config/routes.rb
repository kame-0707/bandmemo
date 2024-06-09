Rails.application.routes.draw do
  root "static_pages#top"
  resources :summaries, only: %i[new create index show edit update destroy]
  resources :users, only: %i[new create]
  resources :voices, only: %i[index create]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
end
