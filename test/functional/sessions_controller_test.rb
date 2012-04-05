require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def logged_in_user
    @user = create(:user)
    session[:userId] = @user.id
  end

  test "Should get new session" do
    get :new
    assert_select '.thirdPartyLogin .fbLink', 1
    assert_select '.thirdPartyLogin .twitterLink', 1
    assert_select 'form#new_user[action="/users"]', 1
    assert_select '#new_user #user_email', 1
    assert_select '#new_user #user_password', 1
    assert_select 'form[action="/session"]', 1
    assert_select '#email', 1
    assert_select '#password', 1
  end
  
  test "shouldn't get new session for logged in user" do
    logged_in_user
    get :new
    assert_redirected_to root_path
  end
  
  test "should log out" do
    logged_in_user
    get :destroy
    assert session[:userId].blank?
  end
end