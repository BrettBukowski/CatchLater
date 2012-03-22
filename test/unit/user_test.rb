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
  
  test "email is normalized" do
    user = User.new(email: ' Foo@bar.com ')
    assert user.valid?
    assert_equal 'foo@bar.com', user.email
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
    user = create(:user, password: 'myPassword')
    assert user.logged_in?('myPassword')
  end
  
  test "user can't log in with the wrong password" do
    user = create(:user, password: '')
    assert !user.logged_in?('a')
  end
  
  test "existing user can log in" do
    user = create(:user, password: 'banana')
    assert !User.log_in(user.email, 'banan')
    assert User.log_in(user.email, 'banana')
  end
  
  test "non-existant user can't log in" do
    assert !User.log_in('blah@foo.bar', 'pass')
  end
  
  test "feed key is generated for creates" do
    user = create(:user)
    assert_equal Digest::MD5.hexdigest(user.email), user.feedKey
  end
  
  test "password reset is sent" do
    user = create(:user)
    user.send_password_reset!
    mail = ActionMailer::Base.deliveries.last
    assert_equal [user.email], mail.to
    assert_equal 'email@catchlater.com', mail[:from].value
    assert_equal 'CatchLater Password Reset', mail.subject
    assert_not_nil user.resetPasswordCodeExpires
    assert_not_nil user.resetPasswordCode
  end
  
  test "find a user based on his twitter account" do
    user = create(:user)
    user.thirdPartyAuthServices[:twitter] = '123abc000'
    user.save
    assert_equal user, User.find_by_third_party_account('twitter', user.thirdPartyAuthServices[:twitter])
  end
  
  test "find a user based on her facebook account" do
    user = create(:user)
    user.thirdPartyAuthServices[:facebook] = '234156777'
    user.save
    assert_equal user, User.find_by_third_party_account('facebook', user.thirdPartyAuthServices[:facebook])
  end
end