class UsersController < ApplicationController
  before_filter :loginRequired, :except => [:new, :create] 
  
  def new
    @user = User.new
    render '/sessions/new'
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      self.currentUser = @user
      redirect_to root_path
    else
      render '/sessions/new'
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