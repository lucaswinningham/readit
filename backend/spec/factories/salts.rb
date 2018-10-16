FactoryBot.define do
  factory :salt do
    user { nil }
    salt_string { "MyString" }
  end
end
