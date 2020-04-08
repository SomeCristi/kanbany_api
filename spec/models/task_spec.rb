require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "Associations" do
    it { should belong_to(:assigned_to).without_validating_presence }
    it { should belong_to(:created_by) }
    it { should belong_to(:column) }

    describe "unassigned tasks" do
      before(:each) do
        @task = build(:task, assigned_to_id: nil)
      end
      it "creates the task" do
        expect(@task).to be_valid
      end
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:task_order) }
  end
end


# TODO test that a user that does not exists cannot be assigned
