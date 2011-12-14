# included in application controller
module Authentication
  # protected
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
    end
    
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're signed in.
    def logged_in?
      !!current_user
    end
    
    # Gets the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (log_in_from_session || log_in_from_basic_auth) unless @current_user == false
    end
    
    # Store the given user id in the session.
    def current_user=(new_user)
      session[:userId] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end
 
    # Check if the user is authorized
    # def authorized?(action=nil, resource=nil, *args)
    #   logged_in?
    # end
 
    # Filter method to enforce a sign_in requirement.
    #
    # To require sign_ins for all actions, use this in your controllers:
    #
    # before_filter :sign_in_required
    #
    # To require sign_ins for specific actions, use this in your controllers:
    #
    # before_filter :sign_in_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    # skip_before_filter :sign_in_required
    #
    def authenticate
      authorized? || access_denied
    end
 
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the sign_in screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action. For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
        # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
        # you may want to change format.any to e.g. format.any(:js, :xml)
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end
 
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:returnTo] = request.fullpath
    end
 
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default. Set an appropriately modified
    # after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_back_or_default(default)
      redirect_to(session[:returnTo] || default)
      session[:returnTo] = nil
    end
    
    # Called from #current_user. First attempt to sign_in by the user id stored in the session.
    def log_in_from_session
      if session[:userId]
        self.current_user = User.find_by_id(session[:userId])
      end
    end
 
    # Called from #current_user. Now, attempt to sign_in by basic authentication information.
    def log_in_from_basic_auth
      authenticate_with_http_basic do |email, password|
        self.current_user = User.authenticate(email, password)
      end
    end
    
    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on sign_in.
    # However, **all session state variables should be unset here**.
    def sign_out!
      # Kill server-side auth cookie
      @current_user = false # not signed in, and don't do it for me
      session[:userId] = nil # keeps the session but kill variable
      # explicitly kill any other session variables you set
    end
 
    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (signed-out to signed-in).
    def sign_out_and_kill_session!
      sign_out!
      reset_session
    end
end
