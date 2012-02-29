class SessionsController < ApplicationController
  layout 'session'
  
  def new
    sign_out!
    @user = User.new
  end
  
  def create
    sign_out!
    if @user = User.log_in(params[:email], params[:password])
      session[:userId] = @user.id
      redirect_to videos_url
    else
      @user = User.new
      render new_session_url
      # redirect_to new_session_url
    end
  end
  
  def create_using_third_party_auth
    if request.env['omniauth.auth'].present?
      third_party_info = request.env['omniauth.auth']
      if user = User.find_by_third_party_account(third_party_info.provider, third_party_info.uid)
        session[:userId] = user.id
        redirect_to videos_url
      elsif third_party_info.info.email
        process_user_email(third_party_info.info.email, third_party_info.provider, third_party_info.uid)
      else
        flash[:email_required] = true
        flash[:user_id] = third_party_info.uid
        flash[:provider] = third_party_info.provider
        redirect_to new_session_url
      end
    else
      flash[:error] = 'Something unexpected happened. Sorry--please try again later'
      redirect_to new_session_url
    end
  end
  
  # User provides an email address to attach the third-party account
  # with any native email+password account
  def provide_email
    if params[:email].present? && params[:uid].present? && params[:provider].present?
      user = User.first(email: params[:email]) || User.new
      user.email = params[:email]
      user.thirdPartyAuthproviders[params[:provider]] = params[:uid]
      if user.save()
        redirect_to videos_url
      else
        respond_to do |format|
          format.html { redirect_to new_session_url, notice: user.errors }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_session_url, notice: "Sorry, but we need an email address to log you in" }
      end
    end
  end
  
  def destroy
    sign_out_and_kill_session!
    redirect_to new_session_url
  end
  
  private
  def process_user_email(email, provider, user_id)
    user = User.first(email: email) || User.new
    user.email = email
    user.thirdPartyAuthproviders[provider] = user_id
    if user.save()
      redirect_to videos_url
    else
      flash[:notice] = user.errors
      redirect_to new_session_url
    end
  end
end