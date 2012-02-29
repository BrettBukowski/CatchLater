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
      flash[:error] = @user.errors
      redirect_to new_session_url
      # render new_session_url
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
    exit if !@user
    @user.send_password_reset! if @user
    redirect_to forgot_password_users_url, notice: "An email has been sent with password reset instructions"
  end
  
  def reset_password
    if !params[:token].present? || !@user = User.first(conditions: {resetPasswordCode: params[:token]})
      error = "The link you used is invalid"
    elsif @user.resetPasswordCodeExpires > DateTime.now
      error = "Whoops! The link you used to reset your password has expired. Please request a new reset email."
    end
    redirect_to(signin_url notice: error) if error
  end
  
  def set_new_password
    if @user = User.first(conditions: {id: params[:id]}) && params[:token].present? && params[:token] == @user.resetPasswordCode
      @user.password = params[:password]
      @user.save
      redirect_to root_path
    else
      redirect_to signin_url notice: "There was an error with the request"
    end
  end
end