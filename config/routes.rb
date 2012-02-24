Catchlater::Application.routes.draw do
  get "home/index"
  root to: "home#index"
  match "queue/push" => "videos#add_to_queue", via: :get
  resources :videos do
    post "toggle_fave", on: :member
    get "faves", on: :collection
    post "set_tags", on: :member
    get "tagged", on: :collection
    get "tags", on: :collection
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
  match "auth/:provider/callback" => "sessions#create_using_third_party_auth"
  match "sessions/provide_email" => "sessions#provide_email", via: :post
end
