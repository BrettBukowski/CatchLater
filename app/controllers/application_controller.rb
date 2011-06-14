class ApplicationController < ActionController::Base
  include Authentication
  protect_from_forgery
  before_filter :storeLocation
  filter_parameter_logging :password
  
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
