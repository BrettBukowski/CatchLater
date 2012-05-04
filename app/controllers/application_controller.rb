class ApplicationController < ActionController::Base
  include Authentication
  helper :all
  protect_from_forgery
  before_filter :store_location
  
  protected
  
  # Before filter for users and videos.
  def login_required
    if !current_user
      flash[:notice] = "You must log in to perform this action"
      redirect_to signin_url
    else
      return true
    end
  end

  # Renders a JSONP response.
  # The name of the callback function
  # to call within the script should
  # be supplied as `callback` in options.
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
