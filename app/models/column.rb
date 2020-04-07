class Column < ApplicationRecord
  # Model associations
  belongs_to :board
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  # Validations
  validates_presence_of :created_by, :name, :board
end
