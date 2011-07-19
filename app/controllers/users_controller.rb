class UsersController < ApplicationController
  
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
end