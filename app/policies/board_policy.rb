class BoardPolicy < ApplicationPolicy
  attr_reader :user, :board

  def initialize(user, board)
    @user = user
    @board = board
  end

  def create?
    user.admin?
  end

  def update?
    create?
  end
end
