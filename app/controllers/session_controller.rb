class SessionController < ApplicationController
  layout 'session'
  
  def new
    signOut!
    @user = User.new
    render 'new'
  end
  
  def create
    @user = User.new
    signOut!
    if @user = User.logIn(params[:email], params[:password])
      session[:userId] = @user.id
      redirectBackOrDefault root_url
    else
      redirect_to :action => :new
    end
  end
  
  def destroy
    signOutAndKillSession!
    redirect_to new_session_url
  end
end