FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { 'test@gmail.com' }
    password { 'Password4&' }
  end
end
