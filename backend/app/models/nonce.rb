class Nonce < ApplicationRecord
  belongs_to :user

  validates :nonce_string, presence: true, allow_blank: false, length: { minimum: 128, maximum: 128 }

  def self.generate_nonce
    Digest::SHA2.new(512).hexdigest(SecureRandom.hex)
  end

  def expired?
    Time.now > Time.at(expiration_at)
  end
end
