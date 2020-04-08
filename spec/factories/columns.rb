FactoryBot.define do
  factory :column do
    name { Faker::Name.name }
    column_order { board.present? ? board.columns.count + 1 : 1}
    board { create(:board) }
    created_by { create(:user) }
  end
end
