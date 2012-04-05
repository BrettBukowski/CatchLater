class SessionsController < ApplicationController
  layout 'session'
  
  # New session.
  # Redirects to root path if the user's
  # already logged in.
  def new
    if current_user
      redirect_to root_path
    else
      @user = User.new
    end
  end
  
  # Creates a new session.
  # Required POST params: email, password
  # Responds to HTML
  def create
    sign_out!
    if @user = User.log_in(params[:email], params[:password])
      log_in @user
    else
      logger.debug User.all.inspect
      logger.debug params.inspect
      @user = User.new
      render 'sessions/new'
    end
  end
  
  # Callback for OmniAuth middleware.
  # Deals with the quirks involved if the user's
  # email isn't supplied
  # Responds to HTML
  def create_using_third_party_auth
    if request.env['omniauth.auth'].present?
      third_party_info = request.env['omniauth.auth']
      if user = User.find_by_third_party_account(third_party_info.provider, third_party_info.uid)
        session[:userId] = user.id
        redirect_to videos_url
      elsif third_party_info.info.email
        process_user_email({ email: third_party_info.info.email, provider: third_party_info.provider, id: third_party_info.uid })
      else
        # head back + pop a dialog prompting for email
        flash[:email_required] = true
        flash[:user_id] = third_party_info.uid
        flash[:provider] = third_party_info.provider
        redirect_to signin_url
      end
    else
      flash[:error] = 'Something unexpected happened. Sorry--please try again later'
      redirect_to signin_url
    end
  end
  
  # User provides an email address to attach the third-party account
  # with any native email+password account
  def provide_email
    process_user_email(params[:user])
  end
  
  # Kills the session
  def destroy
    sign_out_and_kill_session!
    redirect_to signin_url
  end
  
  private
  
  # Sets the session variable and
  # performs the response to logging in
  def log_in(user)
    session[:userId] = user.id
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Welcome!' }
      format.js { render 'redirect' }
    end
  end
  
  # Deals with the email supplied by the 
  # user of a third-party-account.
  # Either creates or retrieves a user
  # for the given email.
  # `user_info` should contain three keys:
  # -email
  # -user_id: third party services' id for user
  # -provider: name of service
  # Responds to HTML, JS
  def process_user_email(user_info)
    email = user_info[:email]
    user_id = user_info[:id]
    provider = user_info[:provider]
    
    if !email.empty? && !user_id.empty? && !provider.empty?
      email.downcase!
      email.strip!
      user = User.first(email: email) || User.new
      user.email = email
      user.thirdPartyAuthServices[provider] = user_id
      if user.save()
        log_in user
      else
        flash[:notice] = user.errors
        redirect_to signin_url
      end
    else
      respond_to do |format|
        format.html { redirect_to signin_url, notice: 'Sorry, but we need an email address to log you in' }
      end
    end
  end
end