Catchlater::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  resources :users, :videos
  resource :session
  match "signin" => "sessions#new", :as => :signin
  match "signout" => "sessions#destroy", :as => :signout
end
