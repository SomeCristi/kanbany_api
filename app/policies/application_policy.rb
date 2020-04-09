class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    not_normal_role?
  end

  def show?
    not_normal_role?
  end

  def create?
    not_normal_role?
  end

  def new?
    create?
  end

  def update?
    not_normal_role?
  end

  def edit?
    update?
  end

  def destroy?
    not_normal_role?
  end

  def not_normal_role?
    !user.normal?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
