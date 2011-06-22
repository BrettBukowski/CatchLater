class HomeController < ApplicationController
  layout 'home'
  
  def index
    if currentUser
      redirect_to videos_url
    end
  end
end
