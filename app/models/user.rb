class User < ApplicationRecord
    require 'securerandom'
  
    # Associations
    has_many :tasks
  
    # Secure password
    has_secure_password
  
    # Validations
    validates_presence_of :username, :email, :password, :password_confirmation
    validates_uniqueness_of :username, :email
  
    # Callbacks
    before_create :set_verification_token_expires_at
    attr_accessor :reset_token
    # Methods
  
    # Generate a new verification token with expiration
    def generate_verification_token
      new_token = SecureRandom.hex(20)
      new_expiry = Time.now + 300.seconds
      update_columns(
        verification_token: new_token,
        verification_token_expires_at: new_expiry
      )
      Rails.logger.info("Verification token and expiration time updated.")
      Rails.logger.info("New Token: #{new_token}")
      Rails.logger.info("New Expiry: #{new_expiry}")
    end
  
    def self.find_by_password_reset_token(token)
      find_by(password_reset_token: token)
    end
  
    def password_reset_token_valid?
      # Check if reset_token_expires_at is in the future
      return false unless reset_token_expires_at
  
      reset_token_expires_at > Time.now
    end
  
    def generate_password_reset_token
      self.password_reset_token = SecureRandom.urlsafe_base64
      self.reset_token_expires_at = 1.hour.from_now
      self.reset_token_used_at = nil  # Reset the token usage timestamp
      update_columns(password_reset_token: self.password_reset_token, reset_token_expires_at: self.reset_token_expires_at, reset_token_used_at: self.reset_token_used_at)
    end  
    
  
    # Check if user is verified
    def verified?
      verified  # Assuming 'verified' is a boolean attribute in the User model
    end
  
    # Check if verification token has expired
    def verification_token_expired?
      verification_token_expires_at.present? && verification_token_expires_at <= Time.now
    end
  
    private
  
    # Set verification token expiration time
    def set_verification_token_expires_at
      self.verification_token_expires_at = Time.now + 300.seconds
    end
  end
  