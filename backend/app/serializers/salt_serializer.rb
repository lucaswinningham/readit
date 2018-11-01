class SaltSerializer
  include FastJsonapi::ObjectSerializer
  attributes :salt_string

  belongs_to :user
end
