Catchlater::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  resources :users, :video
  resource :session
  match "signin" => "session#new", :as => :signin
end
