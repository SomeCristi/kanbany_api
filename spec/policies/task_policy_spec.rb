require 'rails_helper'

describe TaskPolicy do
  subject { described_class }

  permissions :create? do
    it "denies access if not admin" do
      expect(subject).not_to permit(User.new(role: :developer), Task.new())
    end
  end

  permissions :index?, :show?, :update?, :create?, :destroy? do
    it "denies every action for person with normal role" do
      expect(subject).not_to permit(User.new(role: :normal), Task.new())
    end
  end
end
