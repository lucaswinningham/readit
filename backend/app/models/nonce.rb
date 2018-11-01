class Nonce < ApplicationRecord
  belongs_to :user

  validates :nonce_string, presence: true, allow_blank: false, length: { minimum: 24, maximum: 24 }

  def self.generate_nonce
    SecureRandom.base64
  end

  def expired?
    Time.now > Time.at(expiration_at)
  end
end
