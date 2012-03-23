require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    # @user = create(:user)
  end
    
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
    assert_difference('User.count') do
      post :create, user: {email: 'bana@sdf.df', password: ''}
    end
    
    assert_redirected_to root_path
  end
  
  test "should update user" do
    
  end
end