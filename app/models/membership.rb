class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :board

  # Validations
  validates_presence_of :user, :board

  def self.is_member?(user_id, board_id)
    self.where(user_id: user_id, board_id: board_id).exists?
  end

  def self.add_membership(user_id, board_id)
    self.create(user_id: user_id, board_id: board_id)
  end
end
