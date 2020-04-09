class ColumnPolicy < ApplicationPolicy
  attr_reader :user, :column

  def initialize(user, column)
    @user = user
    @column = column
  end

  def create?
    user.admin?
  end

  def update?
    create?
  end
end
