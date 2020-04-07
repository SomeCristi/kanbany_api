require 'rails_helper'

RSpec.describe Column, type: :model do
  describe "Associations" do
    it { should belong_to(:board) }
    it { should belong_to(:created_by) }
  end

  describe "Validations" do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:board) }
  end
end
