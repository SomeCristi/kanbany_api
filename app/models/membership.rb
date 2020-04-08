class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :board

  # Validations
  validates_presence_of :user, :board
end
