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

    it do
      should validate_numericality_of(:task_order).
        is_greater_than(0)
    end

    describe '#check_task_order' do
      let!(:task) { create(:task) }
      let!(:invalid_task) {
        build(:task, task_order: task.task_order + 2)
      }

      before { invalid_task.valid? }

      it 'returns task as not valid' do
        expect(invalid_task.valid?).to eq(false)
      end

      it 'contains an error message' do
        expect(invalid_task.errors.messages[:task_order]).
          to include('must be maximum last task order + 1')
      end
    end

    describe 'assigned_to_user_exists' do
      let!(:task) { build(:task, assigned_to_id: create(:user).id + 100) }

      before { task.valid? }

      it 'returns task as not valid' do
        expect(task.valid?).to eq(false)
      end

      it 'contains an error message' do
        expect(task.errors.messages[:assigned_to_id]).
          to include('has invalid value. User must exist.')
      end
    end
  end

  context 'Callbacks' do
    let!(:column) { create(:column) }
    let!(:first_task) { create(:task, column: column) }
    let!(:second_task) { create(:task, column: column) }
    let!(:third_task) { create(:task, column: column) }

    describe '#change_task_orders' do
      context 'when a new task is added to an pre-existing task order' do
        let!(:new_task) {
          create(:task, column: column, task_order: 2)
        }

        it 'adds the new task at the right task order' do
          expect(new_task.task_order).to eq(2)
        end

        it 'moves the other tasks accordingly' do
          expect(first_task.reload.task_order).to eq(1)
          expect(second_task.reload.task_order).to eq(3)
          expect(third_task.reload.task_order).to eq(4)
        end
      end
    end

    describe "#update_task_orders" do
      context 'when a task is moved up' do
        let!(:fourth_task) { create(:task, column: column) }
        # not the order is first second third fourth task
        before { fourth_task.update(task_order: 2) }

        it 'adds the new task at the right task order' do
          expect(fourth_task.task_order).to eq(2)
        end
        # now it is first fourth second third
        it 'moves the other tasks accordingly' do
          expect(first_task.reload.task_order).to eq(1)
          expect(second_task.reload.task_order).to eq(3)
          expect(third_task.reload.task_order).to eq(4)
        end
      end

      context 'when a column is moved down' do
        let!(:fourth_task) { create(:task, column: column) }
        # not the order is first second third fourth task
        before { second_task.update(task_order: 4) }

        it 'adds the new task at the right task order' do
          expect(second_task.task_order).to eq(4)
        end

        # now it is first third fourth second
        it 'moves the other tasks accordingly' do
          expect(first_task.reload.task_order).to eq(1)
          expect(fourth_task.reload.task_order).to eq(3)
          expect(third_task.reload.task_order).to eq(2)
        end
      end
    end
  end
end


