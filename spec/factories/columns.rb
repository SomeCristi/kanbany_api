FactoryBot.define do
  factory :column do
    name { Faker::Name.name }
    board { create(:board) }
    created_by { create(:user) }
    # order { 1 }
  end
end
# order { board.columns.count + 1 }
