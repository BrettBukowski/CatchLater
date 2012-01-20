Catchlater::Application.routes.draw do
  get "home/index"
  root to: "home#index"
  match "queue/push" => "videos#add_to_queue", via: :get
  resources :videos do
    post "toggle_fave", on: :member
    get "faves", on: :collection
    post "add_tag", on: :member
    post "remove_tag", on: :member
    get "tagged", on: :collection
  end
  resources :users do
    get "forgot_password", on: :collection
    post "send_password_reset", on: :collection
    post "set_new_password", on: :member
  end
  match "reset_password" => "users#reset_password", via: :get
  resource :session
  match "signin" => "sessions#new", as: :signin
  match "signout" => "sessions#destroy", as: :signout
end
