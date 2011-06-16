class SessionsController < ApplicationController
  layout 'session'
  
  def new
    signOut!
    @user = User.new
    render :action => 'new'
  end
  
  def create
    @user = User.new
    signOut!
    if @user = User.logIn(params[:email], params[:password])
      session[:userId] = @user.id
      redirect_to videos_url
      # redirectBackOrDefault root_url
    else
      redirect_to :action => :new
    end
  end
  
  def destroy
    signOutAndKillSession!
    redirect_to new_session_url
  end
end