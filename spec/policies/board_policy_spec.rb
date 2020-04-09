require 'rails_helper'

describe BoardPolicy do
  subject { described_class }

  permissions :update?, :create? do
    it "denies access if not admin" do
      expect(subject).not_to permit(User.new(role: :developer), Board.new())
    end
  end

  permissions :index?, :show?, :update?, :create?, :destroy? do
    it "denies every action for person with normal role" do
      expect(subject).not_to permit(User.new(role: :normal), Board.new())
    end
  end
end
