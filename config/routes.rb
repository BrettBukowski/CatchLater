Catchlater::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  match "/videos/:id/toggleFave" => "videos#toggleFave", :via => :post, :as => :toggle_fave
  match "/videos/faves" => "videos#faves", :via => :get, :as => :faves
  match "queue/push" => "videos#addToQueue", :via => :get
  resources :users, :videos
  resource :session
  match "signin" => "sessions#new", :as => :signin
  match "signout" => "sessions#destroy", :as => :signout
end
