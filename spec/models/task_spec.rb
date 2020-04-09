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

    describe '#assigned_to_user_exists' do
      context 'user does not exist' do
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

      context 'user is not from the board' do
        let!(:user) { create(:user) }
        let!(:task) { build(:task, assigned_to: user) }


        before do
          user.boards.destroy_all
          task.valid?
        end

        it 'returns task as not valid' do
          expect(task.valid?).to eq(false)
        end

        it 'contains an error message' do
          expect(task.errors.messages[:assigned_to_id]).
            to include('must be a member of this board')
        end
      end
    end

    describe '#column_from_same_board' do
      let!(:task) { create(:task) }
      let!(:board) { create(:board) }
      let!(:column) { create(:column, board: board) }

      before do
        task.update(column: column)
        task.valid?
      end

      it 'returns task as not valid' do
        expect(task.valid?).to eq(false)
      end
      it 'contains an error message' do
        expect(task.errors.messages[:column_id]).
          to include('new column must be from the same board')
      end
    end
  end

  context 'Callbacks' do
    let!(:column) { create(:column) }
    let!(:first_task) { create(:task, column: column) }
    let!(:second_task) { create(:task, column: column) }
    let!(:third_task) { create(:task, column: column) }
    let!(:fourth_task) { create(:task, column: column) }

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
      context 'when a task is moved up on the same column' do
        # let!(:fourth_task) { create(:task, column: column) }
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

      context 'when a column is moved down on the same column' do
        # let!(:fourth_task) { create(:task, column: column) }
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

      context 'when a task is moved on another column' do
        let!(:column2) { create(:column, board: column.board) }
        let!(:first_task2) { create(:task, column: column2) }
        let!(:second_task2) { create(:task, column: column2) }
        let!(:third_task2) { create(:task, column: column2) }

        # column 1: first second third fourth
        # column 2: first2 second2 third2
        # move third task from the first column
        # on the second position on column 2
        # new order is:
        # column 1: first second fourth
        # column 2: first2 third second2 third2

        before { third_task.update(column: column2, task_order: 2) }

        it 'adds the task at the right task order on that column' do
          expect(third_task.task_order).to eq(2)
          expect(third_task.column_id).to eq(column2.id)
        end

        # now it is first third fourth second
        it 'moves the other tasks accordingly' do
          expect(first_task.reload.task_order).to eq(1)
          expect(second_task.reload.task_order).to eq(2)
          expect(fourth_task.reload.task_order).to eq(3)

          expect(first_task2.reload.task_order).to eq(1)
          expect(second_task2.reload.task_order).to eq(3)
          expect(third_task2.reload.task_order).to eq(4)
        end
      end
    end

    describe '#rearrange_tasks' do
      context 'when a task is deleted' do
        let!(:third_task) { create(:task, column: column) }

        before { second_task.destroy }

        # first second third fourth-> first third fourth

        it "rearranges collumn accordingly" do
          expect(first_task.reload.task_order).to eq(1)
          expect(third_task.reload.task_order).to eq(2)
          expect(fourth_task.reload.task_order).to eq(3)
        end
      end
    end
  end
end


