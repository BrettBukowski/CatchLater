class User
  include MongoMapper::Document
  
  key :firstName, String, :required => true
  key :lastName, String, :required => true
  key :email, String, :required => true
  key :passwordHash, String
  key :resetPasswordCode, String
  key :resetPasswordCodeExpires, Time
  
  # Validation
  validates_presence_of :firstName, :lastName, :email
  
  
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
    self.resetPasswordCode = Digest::SHA1.hexdigest(seed)
  end
end