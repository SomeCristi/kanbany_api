require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:tasks).dependent(:nullify) }
    it { should have_many(:created_tasks).dependent(:destroy) }
    it { should have_many(:columns) }
    it { should have_many(:boards) }
    it { should have_many(:boards).through(:memberships) }
  end

  describe "Validations" do
    subject { create(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password_digest) }
    it { should validate_uniqueness_of(:email) }

    it "validates email format" do
      email = "wrong"
      expect(build(:user, email: email)).not_to be_valid
    end

    describe "password format" do
      it "validates password's length" do
        password = "Pass&5"
        expect(build(:user, password: password)).not_to be_valid
      end
      it "validates that password is containing at least one number" do
        password = "Password&"
        expect(build(:user, password: password)).not_to be_valid
      end
      it "validates that password is containing at least one uppercase letter" do
        password = "password&5"
        expect(build(:user, password: password)).not_to be_valid
      end
      it "validates that password is containing at least one lowercase letter" do
        password = "PASSWORD&5"
        expect(build(:user, password: password)).not_to be_valid
      end
      it "validates that password is containing at least one symbol" do
        password = "Password5"
        expect(build(:user, password: password)).not_to be_valid
      end
    end
  end
end
