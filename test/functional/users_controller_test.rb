require 'test_helper'

class UsersControllerTest < ActionController::TestCase  
  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select 'form', 1
    assert_select 'form#new_user[action="/users"]', 1
    assert_select '#new_user #user_email', 1
    assert_select '#new_user #user_password', 1
  end
  
  test "should create user" do
    assert_difference 'User.count' do
      post :create, user: {email: 'bansda@sdf.df', password: ''}
    end
    assert_redirected_to root_path
  end
  
  test "should edit user" do
    user = create(:user)
    session[:userId] = user.id
    get :edit, {id: user}
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select "form#edit_user_#{user.id}", 1
    assert_select '#user_password', 1
  end
  
  test "should update user" do
    user = create(:user)
    session[:userId] = user.id
    put :update, id: user.id, user: user.attributes
    assert_redirected_to edit_user_path(user)
  end
  
  test "should show email password reset" do
    get :forgot_password
    assert_response :success
    assert_nil assigns(:user)
    assert_select 'form', 1
    assert_select 'form[action="/users/send_password_reset"]', 1
    assert_select 'input#email', 1
  end
  
  test "should send password reset" do
    user = create(:user)
    post :send_password_reset, email: 'sdf@sdfw.idf'
    assert_redirected_to forgot_password_users_path
  end
  
  test "should show reset password" do
    user = create(:user)
    user.send_password_reset!
    get :reset_password, token: user.resetPasswordCode
    assert_response :success
    assert_select 'form', 1
    assert_select 'input#password', 1
    assert_select 'input#token', 1
  end
  
  test "reset password disallowed with invalid token" do
    get :reset_password
    assert_redirected_to forgot_password_users_path
  end
  
  test "reset password disallowed with expired token" do
    user = create(:user)
    user.send_password_reset!
    user.resetPasswordCodeExpires = DateTime.now
    user.save
    get :reset_password, token: user.resetPasswordCode
    assert_redirected_to forgot_password_users_path
  end
  
  test "should set new password" do
    user = create(:user)
    user.resetPasswordCode = 'banana'
    user.save
    post :set_new_password, id: user.id, password: 'new', token: user.resetPasswordCode 
    assert_redirected_to root_path
  end
  
  test "should delete user" do
    user = create(:user)
    assert_difference 'User.count', -1 do
      session[:userId] = user.id
      delete :destroy, {user: {id: user.id}}
    end
    assert_redirected_to root_path
  end
end