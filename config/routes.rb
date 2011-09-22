Catchlater::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  match '/videos/faves', :controller => 'videos', :action => 'faves'
  resources :users, :videos
  resource :session
  match "signin" => "sessions#new", :as => :signin
  match "signout" => "sessions#destroy", :as => :signout
  match "queue/push" => "videos#addToQueue", :via => :get
end
