class UsersController < ApplicationController
  layout 'session'
  
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
      render '/session/new', :layout => 'session'
    end
  end
end