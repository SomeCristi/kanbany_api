FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "username#{n}" }
    sequence(:email) {|n| "user#{n}@gmail.com" }
    role { :admin }
    password { 'Password4&' }
  end
end
