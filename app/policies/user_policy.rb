class UserPolicy < ApplicationPolicy
  attr_reader :user, :resource

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def change_role?
    user.admin? && !resource.admin?
  end
end
