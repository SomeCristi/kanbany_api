class Task < ApplicationRecord
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  belongs_to :assigned_to, class_name: "User", foreign_key: "assigned_to_id", optional: true

  validates_presence_of :created_by, :name, :order
end
