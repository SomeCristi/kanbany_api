FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "username#{n}" }
    sequence(:email) {|n| "user#{n}@gmail.com" }
    password { 'Password4&' }
  end
end
