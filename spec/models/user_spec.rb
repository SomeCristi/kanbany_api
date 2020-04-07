require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:tasks).dependent(:nullify) }
    it { should have_many(:created_tasks).dependent(:destroy) }
    it { should have_many(:boards) }
    it { should have_many(:columns) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password_digest) }
  end
end
