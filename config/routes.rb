Catchlater::Application.routes.draw do
  get "home/index"
  get "bookmarklet" => "home#bookmarklet"
  root to: "home#index"
  resources :videos do
    post "toggle_fave", on: :member
    get "faves", on: :collection
    post "set_tags", on: :member
    get "tagged", on: :collection
    get "tags", on: :collection
    get "feed", on: :collection
    get "bookmark", on: :collection
  end
  resources :users do
    get "forgot_password", on: :collection
    post "send_password_reset", on: :collection, via: :post
    post "set_new_password", on: :member, via: :post
  end
  get "reset_password" => "users#reset_password"
  resource :session
  match "signin" => "sessions#new", as: :signin, via: :get
  match "signout" => "sessions#destroy", as: :signout, via: :get
  get "auth/:provider/callback" => "sessions#create_using_third_party_auth"
  get "auth/failure" => "sessions#new"
  post "sessions/provide_email" => "sessions#provide_email"
end
