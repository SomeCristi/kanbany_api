class TaskPolicy < ApplicationPolicy
  attr_reader :user, :task

  def initialize(user, task)
    @user = user
    @task = task
  end

  def create?
    user.admin? || user.project_manager?
  end

  def destroy?
    user.admin? || user.project_manager?
  end
end
