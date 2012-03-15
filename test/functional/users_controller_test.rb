class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create user" do
    
  end
  
  test "should update user" do
    
  end
end