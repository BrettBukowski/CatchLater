class SessionsController < ApplicationController
  layout 'session'
  
  def new
    sign_out!
    @user = User.new
  end
  
  def create
    sign_out!
    if @user = User.log_in(params[:email], params[:password])
      session[:userId] = @user.id
      redirect_to videos_url
    else
      @user = User.new
      redirect_to new_session_url
    end
  end
  
  def create_using_third_party_auth
    if request.env['omniauth.auth'].present?
      third_party_info = request.env['omniauth.auth']
      if user = User.find_by_third_party_account(third_party_info.service, third_party_info.uid)
      
      else
      
      end
      if third_party_info.info.email
        user = User.first(email: third_party_info.info.email) || User.new
        user.email = third_party_info.info.email
        user.thirdPartyAuthServices[third_party_info.service] = third_party_info.uid
        if user.save()
          redirect_to videos_url
        else
          flash[:notice] = user.errors
          redirect_to new_session_url
      else
        
      end
    else
      
    end
    # render text: request.env['omniauth.auth'].inspect
    # TK - if not given email...
    # stash provider+uid in flash
    # redirect to signin_url
    # pop dialog
    # get email
    # come back here
    # create / update user
    # redirect to videos_url
  end
  
  # User provides an email address to attach the third-party account
  # with any native email+password account
  def provide_email
    if params[:email].present? && params[:uid].present? && params[:service].present?
      user = User.first(email: params[:email]) || User.new
      user.email = params[:email]
      user.thirdPartyAuthServices[params[:service]] = params[:uid]
      if user.save()
        redirect_to videos_url
      else
        flash[:notice] = user.errors
        redirect_to new_session_url
    else
      flash[:notice] = "Sorry, but we need an email address to log you in"
      redirect_to new_session_url
    end
  end
  
  def destroy
    sign_out_and_kill_session!
    redirect_to new_session_url
  end
end