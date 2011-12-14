class HomeController < ApplicationController
  layout 'home'
  
  def index
    if current_user
      redirect_to videos_url
    end
  end
end
