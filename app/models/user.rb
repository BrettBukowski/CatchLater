require 'digest/sha1'
require 'bcrypt'

class User
  include MongoMapper::Document
  include BCrypt
  
  before_create :create_feed_key
  
  key :email,                     String
  key :passwordHash,              String
  key :resetPasswordCode,         String
  key :resetPasswordCodeExpires,  Time
  key :thirdPartyAuthServices,    Hash
  key :feedKey,                   String
  
  # Relationships
  has_many :videos, dependent: :destroy
  
  # Validation
  EMAIL_REGEX = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
  THIRD_PARTY_SERVICES = %w[facebook twitter]
  THIRD_PARTY_ID_REGEX = /^[0-9a-zA-Z]+$/i

  validates :email, presence: true, uniqueness: true, length: { in: 6..100 },
    format: {with: EMAIL_REGEX, message: "The email you entered is invalid"}
  validate :validate_third_party_services
  
  # Retrieves the user for the given email
  # confirms that the password is legit.
  # Returns User instance or nil
  def self.log_in(email, password)
    user = User.first({email: email.downcase})
    user && user.logged_in?(password) ? user : nil
  end
  
  # Checks if the password is valid.
  # Returns Boolean
  def logged_in?(pass)
    password == pass
  end
  
  # Gets the password hash.
  # Returns String or nil if passwordHash isn't present
  def password
    if passwordHash.present?
      @password ||= Password.new(passwordHash)
    else
      nil
    end
  end
  
  # Sets the password hash.
  # newValue should be a String
  # Returns String
  def password=(newValue='')
    @password = newValue
    self.passwordHash = Password.create(newValue)
  end
  
  # Sets the email.
  # Trims and lowercases it.
  # Returns String
  def email=(newEmail)
    newEmail.downcase!
    newEmail.strip!
    write_attribute(:email, newEmail)
  end
  
  # Sends a password reset email
  # and sets resetPasswordCodeExpires
  # and resetPasswordCode.
  def send_password_reset!
    self.resetPasswordCodeExpires = 1.day.from_now
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.resetPasswordCode = Digest::SHA1.hexdigest(seed)
    self.save
    UserMailer.password_reset(self).deliver
  end
  
  # Finds a user by a third-party user id on
  # the specified service
  # Returns User or nil if not found
  def self.find_by_third_party_account(service, user_id)
    User.where("thirdPartyAuthServices.#{service}" => user_id).first
  end
  
  private
  
  # Validator for thirdPartyAuthServices.
  # Makes sure only supported services are added
  # and that values are valid user ids.
  def validate_third_party_services
    if !thirdPartyAuthServices.empty?
      thirdPartyAuthServices.each do |key, value|
        if !THIRD_PARTY_SERVICES.include?(key) || !THIRD_PARTY_ID_REGEX.match(value)
          errors.add(:thirdPartyAuthServices, "There's a problem with the #{key} account")
        end
      end
    end
  end
  
  # Sets feedKey before creation.
  def create_feed_key
    write_attribute(:feedKey, Digest::MD5.hexdigest(self.email))
  end

  # Keep feedKey attribute restricted for external assignment.
  def feedKey=(val)
    feedKey = val
  end
end