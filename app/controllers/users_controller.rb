class UsersController < ApplicationController
  force_ssl
  # Require login for user-modifiable methods
  before_filter :login_required, only: [:edit, :update, :destroy]
  # redirect logged-in users away from non-logged in methods
  before_filter :redirect_logged_in_user, only: [:new, :create, :send_password_reset, :forgot_password, :reset_password, :set_new_password]

  # New user.
  # Redirects to root path
  # if the user's already
  # logged in.
  def new
    @user = User.new
  end

  # Creates a new user from params.
  # Responds to HTML
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        self.current_user = @user
        format.html { redirect_to videos_url, notice: 'Welcome!' }
      else
        format.html { render 'sessions/new' }
      end
    end
  end

  # Renders user edit view.
  def edit
    @user = current_user
  end

  # Updates the user with the supplied params.
  # Required PUT params: id
  # Responds to HTML, JSON
  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(allowed_params)
        format.html { redirect_to edit_user_path(@user), notice: "You've been updated!" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Destroys the specified user.
  # Required DELETE params: user
  # Responds to HTML
  def destroy
    @user = current_user
    sign_out_and_kill_session!
    @user.destroy
    redirect_to root_path
  end

  # Sends password reset.
  # Required POST params: email
  # Responds to HTML, JS
  def send_password_reset
    @user = User.first(conditions: {email: params[:email].downcase})
    @user.send_password_reset! if @user
    respond_to do |format|
      format.html { redirect_to forgot_password_users_url, notice: "An email has been sent with password reset instructions" }
      format.js
    end
  end

  # Renders the reset password view
  # if the given values are acceptable.
  # Required GET params: token
  def reset_password
    if !params[:token].present? || !@user = User.first(conditions: {resetPasswordCode: params[:token]})
      error = "The link you used is invalid"
    elsif @user.resetPasswordCodeExpires < DateTime.now
      error = "Whoops! The link you used to reset your password has expired. Please request a new reset email."
    end
    redirect_to(forgot_password_users_url, notice: error) if error
  end

  # Sets a new password for the user
  # filling out the form on #reset_password.
  # Required POST params: token, id
  # Responds to HTML
  def set_new_password
    @user = User.find(params[:id])
    if @user && params[:token].present? && params[:token] == @user.resetPasswordCode
      @user.password = params[:password]
      @user.save
      session[:userId] = @user.id
      redirect_to root_path, notice: "Your new password has been saved"
    else
      redirect_to signin_url, notice: "There was an error with the request"
    end
  end

  protected
  def redirect_logged_in_user
    redirect_to root_path if current_user
  end

  private
  # Allowable params to set via
  # #update mass-assignment.
  def allowed_params
    params[:user].slice(:password)
  end
end