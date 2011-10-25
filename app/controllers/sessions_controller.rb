class SessionsController < ApplicationController
  
  def new
    signOut!
    @user = User.new
  end
  
  def create
    signOut!
    if @user = User.logIn(params[:email], params[:password])
      session[:userId] = @user.id
      redirect_to videos_url
    else
      @user = User.new
      redirect_to new_session_url
    end
  end
  
  def destroy
    signOutAndKillSession!
    redirect_to new_session_url
  end
end