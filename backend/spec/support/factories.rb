FactoryBot.define do
  factory :user do
    name { 'goat' }
    email { 'goat@email.com' }
  end

  factory :sub do
    name { 'funny' }
  end

  factory :post do
    user
    sub
    title { 'Lorem ipsum' }
    url { 'https://www.github.com' }
  end
end
