require 'digest/sha1'
require 'bcrypt'

class User
  include MongoMapper::Document
  include BCrypt
  
  key :email,                     String, required: true
  key :passwordHash,              String
  key :resetPasswordCode,         String
  key :resetPasswordCodeExpires,  Time
  
  # Relationships
  has_many :videos, dependent: :destroy
  
  # Validation
  EMAIL_REGEX = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
  validates_presence_of :email
  validates_length_of   :email, within: 6..100
  validates_format_of   :email, with: EMAIL_REGEX
  
  def self.logIn(email, password)
    user = User.first(conditions: {email: email.downcase})
    user && user.loggedIn?(password) ? user : nil
  end
  
  def loggedIn?(pass)
    password == pass
  end
  
  def password
    if passwordHash.present?
      @password ||= Password.new(passwordHash)
    else
      nil
    end
  end
  
  def password=(newValue='')
    @password = newValue
    self.passwordHash = Password.create(newValue)
  end
  
  def email=(newEmail)
    newEmail.downcase!
    write_attribute(:email, newEmail)
  end
  
  def resetPassword!
    self.resetPasswordCodeExpires = 1.day.from_now
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.resetPasswordCode = Digest::SHA1.hexdigest(seed)
    save!
  end
end