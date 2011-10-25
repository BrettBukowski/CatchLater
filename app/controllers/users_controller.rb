class UsersController < ApplicationController
  before_filter :loginRequired, :except => [:new, :create] 

  def new
    @user = User.new
    render new_session_url#'/sessions/new'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      self.currentUser = @user
      redirect_to root_path, notice: "You're all set! Start grabbing videos"
    else
      render new_session_url#'/sessions/new'
    end
  end

  def edit
    @user = currentUser
  end

  def destroy
    @user = currentUser
    signOutAndKillSession!
    @user.destroy
    redirect_to root_path
  end
end