class HomeController < ApplicationController
  layout 'home', :except => :bookmarklet
  
  def index
    redirect_to videos_url if current_user
  end

  def bookmarklet
    render action: 'bookmarklet', layout: 'application'
  end
end
