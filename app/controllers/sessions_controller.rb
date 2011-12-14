class SessionsController < ApplicationController
  
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
  
  def destroy
    sign_out_and_kill_session!
    redirect_to new_session_url
  end
end