FactoryBot.define do
  factory :nonce do
    user { nil }
    nonce_string { "MyString" }
    expiration_at { "2018-10-13 00:24:36" }
  end
end
