require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "Associations" do
    it { should belong_to(:assigned_to).without_validating_presence }
    it { should belong_to(:created_by) }
  end

  describe "Validations" do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:order) }
  end
end
