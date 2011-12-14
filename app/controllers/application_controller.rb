class ApplicationController < ActionController::Base
  include Authentication
  helper :all
  protect_from_forgery
  before_filter :store_location
  
  protected
  
  def login_required
    if !current_user
      flash[:notice] = "Log in"
      redirect_to signin_url
    else
      return true
    end
  end

  def render_jsonp(json, options={})
    callback = params[:callback]
    response = begin
      if callback
        "#{callback}(#{json});"
      else
        json
      end
    end
    render({:content_type => :js, :text => response}.merge(options))
  end
end
