require 'digest/sha1'
require 'bcrypt'

class User
  include MongoMapper::Document
  include BCrypt
  
  before_validation :create_feed_key, on: :create
  
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
  THIRD_PARTY_ID_REGEX = /[0-9a-zA-Z]+/i

  validates :email, presence: true, uniqueness: true, length: { in: 6..100 },
    format: {with: EMAIL_REGEX, message: "The email you entered is invalid"}
  validate :validate_third_party_services
  
  def self.log_in(email, password)
    user = User.first({email: email.downcase})
    user && user.logged_in?(password) ? user : nil
  end
  
  def logged_in?(pass)
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
    newEmail.strip!
    write_attribute(:email, newEmail)
  end
  
  def send_password_reset!
    self.resetPasswordCodeExpires = 1.day.from_now
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.resetPasswordCode = Digest::SHA1.hexdigest(seed)
    self.save
    UserMailer.password_reset(self).deliver
  end
  
  def self.find_by_third_party_account(service, user_id)
    User.where("thirdPartyAuthServices.#{service}" => user_id).first
  end
  
  private
  def validate_third_party_services
    if !thirdPartyAuthServices.empty?
      thirdPartyAuthServices.each do |key, value|
        if !THIRD_PARTY_SERVICES.include?(key) || !THIRD_PARTY_ID_REGEX.match(value)
          errors.add(:thirdPartyAuthServices, "There's a problem with the #{key} account")
        end
      end
    end
  end
  
  def create_feed_key
    self.feedKey = Digest::MD5.hexdigest(self.email)
  end

  # Keep feedKey attribute restricted for external assignment
  def feedKey=(val)
    self.feedKey = val
  end
end