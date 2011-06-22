class UsersController < ApplicationController
  
  def new
    @user = User.new
    render '/session/new'
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      self.currentUser = @user
      redirect_to root_path
    else
      render '/session/new'
    end
  end
end