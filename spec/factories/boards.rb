FactoryBot.define do
  factory :board do
    name { Faker::Name.name }
    created_by { create(:user) }
  end
end
