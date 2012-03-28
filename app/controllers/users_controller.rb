class UsersController < ApplicationController
  # Require login for user-modifiable methods
  before_filter :login_required, :except => [:new, :create, :send_password_reset, :forgot_password, :reset_password]

  # New user.
  # Redirects to root path
  # if the user's already
  # logged in
  def new
    if current_user
      redirect_to root_path
    else
      @user = User.new
    end
  end

  # Creates a new user from params.
  # Responds to HTML, JS
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        self.current_user = @user
        format.html { redirect_to root_path, notice: "You're all set! Start grabbing videos" }
      else
        format.html do
          flash[:error] = @user.errors
          redirect_to new_session_url
        end
        format.js
      end
    end
  end

  # Renders user edit view.
  def edit
    @user = current_user
  end
  
  # Updates the user with the supplied params
  # Required POST params: id
  # Responds to HTML, JSON
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user && @user == current_user && @user.update_attributes(allowed_params)
        format.html { redirect_to edit_user_path(@user), notice: "You've been updated!" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Destroys the specified user
  # Required DELETE params: user
  # Responds to HTML
  def destroy
    @user = User.first(params[:user])
    if @user == current_user
      sign_out_and_kill_session!
      @user.destroy
    end
    redirect_to root_path
  end
  
  # Sends password reset.
  # Required POST params: email
  # Responds to HTML
  def send_password_reset
    @user = User.first(conditions: {email: params[:email].downcase})
    @user.send_password_reset! if @user
    respond_to do |format|
      format.html redirect_to forgot_password_users_url, notice: "An email has been sent with password reset instructions"
      format.json
    end
  end

  # Renders the reset password view
  # if the given values are acceptable
  # Required GET params: token
  def reset_password
    if !params[:token].present? || !@user = User.first(conditions: {resetPasswordCode: params[:token]})
      error = "The link you used is invalid"
    elsif @user.resetPasswordCodeExpires > DateTime.now
      error = "Whoops! The link you used to reset your password has expired. Please request a new reset email."
    end
    redirect_to(signin_url notice: error) if error
  end
  
  # Sets a new password for the user
  # filling out the form on #reset_password
  # Required POST params: token, id
  # Responds to HTML
  def set_new_password
    if @user = User.first(conditions: {id: params[:id]}) && params[:token].present? && params[:token] == @user.resetPasswordCode
      @user.password = params[:password]
      @user.save
      redirect_to root_path, notice "Your new password has been saved"
    else
      redirect_to signin_url, notice: "There was an error with the request"
    end
  end
  
  private
  # Allowable params to set via
  # #update mass-assignment
  def allowed_params
    params[:user].slice(:password)
  end
end