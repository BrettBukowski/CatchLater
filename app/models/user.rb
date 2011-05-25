class User
  include MongoMapper::Document
  
  key :email, String, :required => true
  key :passwordHash, String
  key :resetPasswordCode, String
  key :resetPasswordCodeExpires, Time
  
  # Validation
  validates_presence_of :email
  
  def self.logIn(email, password)
    user = User.first(:conditions => {:email => email.downcase})
    user && user.loggedIn?(password) ? user : nil
  end
  
  def loggedIn?(pass)
    password == pass
  end
  
  def password
    if passwordHash.present?
      @password ||= Bcrypt::Password.new(passwordHash)
    else
      nil
    end
  end
  
  def password=(newValue='')
    @password = newValue
    self.passwordHash = Bcrypt::Password.create(newValue)
  end
  
  def email=(newEmail)
    newEmail.downcase! unless newEmail.nil
    write_attribute(:email, newEmail)
  end
  
  def resetPassword!
    self.resetPasswordCodeExpires = 1.day.from_now
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.resetPasswordCode = Digest::SHA1.hexdigest(seed)
    save!
  end
end