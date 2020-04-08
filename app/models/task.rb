class Task < ApplicationRecord
  # Model associations
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  # a ticket can be unassigned
  belongs_to :assigned_to, class_name: "User", foreign_key: "assigned_to_id", optional: true
  belongs_to :column

  # Validations
  validates :created_by, :title, :task_order, :column, presence: true
end
