require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "email is required" do
    user = User.new
    assert user.invalid?
    assert user.errors[:email].any?
  end
  
  test "password isn't required" do
    user = User.new(email: 'abc@def.ds')
    assert user.valid?
  end
  
  test "email must be an email" do
    user = User.new(email: 'foo')
    assert user.invalid?
    assert_equal 'is too short (minimum is 6 characters)', user.errors[:email][0] 
    
    user.email = 'a@a.b'
    assert user.invalid?
    assert_equal 'is too short (minimum is 6 characters)', user.errors[:email][0]
    
    user.email = 'a' * 101
    assert user.invalid?
    assert_equal 'is too long (maximum is 100 characters)', user.errors[:email][0]
    
    user.email = 'asdfsdf@sdfdf'
    assert user.invalid?
    assert_equal 'The email you entered is invalid', user.errors[:email][0]
    
    user.email = 'abc@def.com'
    assert user.valid?
  end
  
  test "email must be unique" do
    user = create(:user)
    dupe = User.new(email: user.email)
    assert dupe.invalid?
  end
    
  test "third party services must be legit" do
    user = User.new(email: 'abc@def.com')
    
    user.thirdPartyAuthServices = {}
    assert user.valid?
    
    user.thirdPartyAuthServices = {linkedIn: 'banana'}
    assert user.invalid?
    
    user.thirdPartyAuthServices = {Facebook: 'sdf23424'}
    assert user.invalid?
    
    user.thirdPartyAuthServices = {Twitter: 'sdf23424'}
    assert user.invalid?
    
    user.thirdPartyAuthServices = {facebook: 'sd@$ssdf'}
    assert user.invalid?
    
    user.thirdPartyAuthServices = {twitter: 'sd#f23424'}
    assert user.invalid?
    
    user.thirdPartyAuthServices = {twitter: '98dfsASD'}
    assert user.valid?
    
    user.thirdPartyAuthServices = {facebook: 'sdf23424'}
    assert user.valid?
    
    user.thirdPartyAuthServices['twitter'] = '1232423123'
    assert user.valid?
  end
  
  test "log user in" do
    
  end
  
  test "user can't log in with the wrong password" do
    
  end
end