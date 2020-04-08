class Board < ApplicationRecord
  # Model associations
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  has_many :columns
  has_many :memberships
  has_many :users, through: :memberships

  # Validations
  validates_presence_of :created_by, :name

  # Callbacks

  # it's called after the board is created
  after_create :add_creator_as_member

  private

  # add the user that created the board as a member of the board
  def add_creator_as_member
    Membership.add_membership(created_by_id, id)
  end
end
