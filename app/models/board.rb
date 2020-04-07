class Board < ApplicationRecord
  # Model associations
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  has_many :columns

  # Validations
  validates_presence_of :created_by, :name
end
