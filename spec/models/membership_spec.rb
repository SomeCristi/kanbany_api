require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe "Associations" do
    it { should belong_to(:board) }
    it { should belong_to(:user) }
  end
end
