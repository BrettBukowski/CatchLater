class HomeController < ApplicationController
  def index
    if currentUser
      redirect_to videos_url
    end
  end
end
