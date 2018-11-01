class NonceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :nonce_string

  belongs_to :user
end
