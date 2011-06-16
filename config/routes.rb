Catchlater::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  resources :users, :videos
  resource :session
  match "signin" => "session#new", :as => :signin
  match "signout" => "session#destroy", :as => :signout
end
