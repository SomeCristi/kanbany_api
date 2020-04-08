FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    created_by { create(:user) }
    task_order { column.present? ? column.tasks.count + 1 : 1}
    column { create(:column) }
  end
end

