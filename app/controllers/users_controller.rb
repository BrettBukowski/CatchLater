class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :send_password_reset, :forgot_password, :reset_password]

  def new
    @user = User.new
    render new_session_url
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      redirect_to root_path, notice: "You're all set! Start grabbing videos"
    else
      render new_session_url
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
    @user = User.first(conditions: {email: params[:email].downcase})
    @user.send_password_reset! if @user
    redirect_to request.referer notice: "An email has been sent with password reset instructions"
  end
  
  def reset_password
    if params[:token].present? && @user = User.first(conditions: {resetPasswordCode: params[:token]})
  end
  
  def set_new_password
    unless params[:token].present? && @user = User.first(conditions: {resetPasswordCode: params[:token]})
      
  end
end