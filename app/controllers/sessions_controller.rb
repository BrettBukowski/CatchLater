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
    render :text => request.env['omniauth.auth'].inspect
    # TK - if not given email...
    # stash provider+uid in flash
    # redirect to signin_url
    # pop dialog
    # get email
    # come back here
    # create / update user
    # redirect to videos_url
  end
  
  def destroy
    sign_out_and_kill_session!
    redirect_to new_session_url
  end
end