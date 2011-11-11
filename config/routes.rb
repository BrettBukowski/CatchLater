Catchlater::Application.routes.draw do
  get "home/index"
  root to: "home#index"
  match "queue/push" => "videos#addToQueue", via: :get
  resources :videos do
    post 'toggle_fave', on: :member
    get 'faves', on: :collection
    post 'add_tag', on: :member
    post 'remove_tag', on: :member
    get 'tagged', on: :collection
  end
  resources :users
  resource :session
  match "signin" => "sessions#new", as: :signin
  match "signout" => "sessions#destroy", as: :signout
end
