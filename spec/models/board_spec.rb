require 'rails_helper'

RSpec.describe Board, type: :model do
  describe "Associations" do
    it { should belong_to(:created_by) }
  end

  describe "Validations" do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:name) }
  end
end
