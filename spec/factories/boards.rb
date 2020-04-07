FactoryBot.define do
  factory :board do
    name { "Board" }
    created_by { create(:user) }
  end
end
