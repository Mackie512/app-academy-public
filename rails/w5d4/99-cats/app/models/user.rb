class User < ApplicationRecord

    validates :username, :session_token, uniqueness: true, presence: true
    validates :password_digest, presence: true
    validates :password, length: { minimum: 6, allow_nil: true }

    attr_reader :password
    
    after_initialize :ensure_session_token

    def self.find_by_credentials(username, password)
      user = User.find_by(username: params[:username])

      return nil if user.nil?

      user && user.is_password?(password) ? user : nil
    end

    def password=(password) #hunter12
      self.password_digest = BCrypt::Password.create(password)
      @password = password
    end

    def is_password?(password)
      BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def reset_session_token!
      self.session_token = SecureRandom.urlsafe_base64(16)
      self.save
      self.session_token
    end


    private

    def ensure_session_token
      self.session_token ||= SecureRandom.urlsafe_base64(16)
    end

end