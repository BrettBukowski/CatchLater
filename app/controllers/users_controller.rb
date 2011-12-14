class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create] 

  def new
    @user = User.new
    render new_session_url#'/sessions/new'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      redirect_to root_path, notice: "You're all set! Start grabbing videos"
    else
      render new_session_url#'/sessions/new'
    end
  end

  def edit
    @user = current_user
  end

  def destroy
    @user = current_user
    sign_out_and_kill_session!
    @user.destroy
    redirect_to root_path
  end
  
  def send_password_reset
    if @user = User.find(:first, :conditions : {email: params[:email]})
      
  end
  
  def reset_password
    
  end
end