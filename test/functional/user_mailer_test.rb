class UserMailerTest < ActionMailer::TestCase
  def test_password_reset
    user = users(:user1)
    
    email = UserMailer.password_reset(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [user.email], email.to
    assert_equal "CatchLater Password Reset", email.subject
    # assert_match(, 
    # assert_match(, 
  end
end