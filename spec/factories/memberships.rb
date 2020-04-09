FactoryBot.define do
  factory :membership do
    user { create(:user) }
    board { create(:board) }
  end
end

