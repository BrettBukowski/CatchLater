class UserMailer < ActionMailer::Base
  default from: 'email@catchlater.com'
  
  def password_reset(user)
    @user = user
    mail(to: user.email, subject: "CatchLater Password Reset")
  end
end