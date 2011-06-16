class ApplicationController < ActionController::Base
  include Authentication
  helper :all
  protect_from_forgery
  before_filter :storeLocation
  
  protected
  
  def loginRequired
    if !currentUser
      flash[:notice] = "Log in"
      redirect_to signin_url
    else
      return true
    end
  end
end
