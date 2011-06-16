# included in application controller
module Authentication
  # protected
    # Inclusion hook to make #currentUser and #loggedIn?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :currentUser, :loggedIn? if base.respond_to? :helper_method
    end
    
    # Returns true or false if the user is logged in.
    # Preloads @currentUser with the user model if they're signed in.
    def loggedIn?
      !!currentUser
    end
    
    # Gets the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def currentUser
      @currentUser ||= (logInFromSession || logInFromBasicAuth) unless @currentUser == false
    end
    
    # Store the given user id in the session.
    def currentUser=(newUser)
      session[:userId] = newUser ? newUser.id : nil
      @currentUser = newUser || false
    end
 
    # Check if the user is authorized
    # def authorized?(action=nil, resource=nil, *args)
    #   loggedIn?
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
      authorized? || accessDenied
    end
 
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the sign_in screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action. For example, a popup window might
    # simply close itself.
    def accessDenied
      respond_to do |format|
        format.html do
          storeLocation
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
    # We can return to this location by calling #redirectBackOrDefault.
    def storeLocation
      session[:returnTo] = request.fullpath
    end
 
    # Redirect to the URI stored by the most recent storeLocation call or
    # to the passed default. Set an appropriately modified
    # after_filter :storeLocation, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirectBackOrDefault(default)
      redirect_to(session[:returnTo] || default)
      session[:returnTo] = nil
    end
    
    # Called from #currentUser. First attempt to sign_in by the user id stored in the session.
    def logInFromSession
      if session[:userId]
        self.currentUser = User.find_by_id(session[:userId])
      end
    end
 
    # Called from #currentUser. Now, attempt to sign_in by basic authentication information.
    def logInFromBasicAuth
      authenticate_with_http_basic do |email, password|
        self.currentUser = User.authenticate(email, password)
      end
    end
    
    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on sign_in.
    # However, **all session state variables should be unset here**.
    def signOut!
      # Kill server-side auth cookie
      @currentUser = false # not signed in, and don't do it for me
      session[:userId] = nil # keeps the session but kill variable
      # explicitly kill any other session variables you set
    end
 
    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (signed-out to signed-in).
    def signOutAndKillSession!
      signOut!
      reset_session
    end
end
