class UserMailerTest < ActionMailer::TestCase
  def test_password_reset
    user = create(:user)
    
    email = UserMailer.password_reset(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [user.email], email.to
    assert_equal "CatchLater Password Reset", email.subject
  end
end