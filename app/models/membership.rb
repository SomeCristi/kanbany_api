class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :board

  # Validations
  validates :user, :board, presence: true
  validates :user_id, uniqueness: { scope: :board_id }

  def self.is_member?(user_id, board_id)
    self.where(user_id: user_id, board_id: board_id).exists?
  end

  def self.add_membership(user_id, board_id)
    self.create(user_id: user_id, board_id: board_id)
  end
end
