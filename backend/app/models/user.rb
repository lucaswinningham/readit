class User < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[A-Za-z0-9_\-]+\Z/
  validates :name, presence: true, allow_blank: false, uniqueness: true,
                   format: { with: VALID_NAME_REGEX }, length: { minimum: 3, maximum: 20 }

  has_many :posts, dependent: :nullify
  before_destroy :deactivate_posts, prepend: true

  def to_param
    name
  end

  # password validations

  has_one :salt, dependent: :destroy

  has_one :nonce, dependent: :destroy

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest).is_password?(unencrypted_password) && self
  end

  def password=(unencrypted_password)
    self.password_digest = BCrypt::Password.create(unencrypted_password)
  end

  def make_session
    payload = { sub: name }
    token = JwtService.encode(payload: payload)
    OpenStruct.new({ id: nil, user_name: name, token: token })
  end

  private

  def deactivate_posts
    posts.update_all(active: false)
  end
end
