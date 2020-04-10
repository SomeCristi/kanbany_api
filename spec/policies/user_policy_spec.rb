require 'rails_helper'

describe UserPolicy do
  subject { described_class }

  permissions :change_role? do
    it "denies access if not admin" do
      expect(subject).not_to permit(User.new(role: :developer), User.new())
    end

    it "denies access the other user is also admin" do
      expect(subject).not_to permit(User.new(role: :admin), User.new(role: :admin))
    end
  end

  permissions :index?, :show?, :update?, :create?, :destroy? do
    it "denies every action for person with normal role" do
      expect(subject).not_to permit(User.new(role: :normal), User.new())
    end
  end
end
