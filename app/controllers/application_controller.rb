class ApplicationController < ActionController::Base
  protect_from_forgery
  
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
