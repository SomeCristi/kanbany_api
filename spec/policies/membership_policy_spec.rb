require 'rails_helper'

describe MembershipPolicy do
  subject { described_class }

  permissions :create? do
    it "denies access if not admin or project manager" do
      expect(subject).not_to permit(User.new(role: :developer), Membership.new())
    end

  permissions :index?, :show?, :update?, :create?, :destroy? do
    it "denies every action for person with normal role" do
      expect(subject).not_to permit(User.new(role: :normal), Membership.new())
    end
  end
  end
end
