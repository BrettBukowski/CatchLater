Catchlater::Application.routes.draw do
  get "home/index"
  root to: "home#index"
  match "queue/push" => "videos#addToQueue", via: :get
  resources :videos do
    post 'toggle_fave', on: :member
    get 'faves', on: :collection
  end
  resources :users
  resource :session
  match "signin" => "sessions#new", as: :signin
  match "signout" => "sessions#destroy", as: :signout
end
