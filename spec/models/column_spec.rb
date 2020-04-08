require 'rails_helper'

RSpec.describe Column, type: :model do
  describe 'Associations' do
    it { should belong_to(:board) }
    it { should belong_to(:created_by) }
    it { should have_many(:tasks) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:board) }
    it { should validate_presence_of(:column_order) }

    it do
      should validate_numericality_of(:column_order).
        is_greater_than(0)
    end

    describe '#check_column_order' do
      let!(:column) { create(:column) }
      let!(:invalid_column) {
        build(:column, column_order: column.column_order + 2)
      }

      before { invalid_column.valid? }

      it 'returns board as not valid' do
        expect(invalid_column.valid?).to eq(false)
      end

      it 'contains an error message' do
        expect(invalid_column.errors.messages[:column_order]).
          to include('must be maximum last column order + 1')
      end
    end

    describe '#change_column_orders' do
      context 'when a new column is added to an pre-existing column order' do
        let!(:board) { create(:board) }
        let!(:first_column) { create(:column, board: board) }
        let!(:second_column) { create(:column, board: board) }
        let!(:third_column) { create(:column, board: board) }

        let!(:new_column) {
          create(:column, board: board, column_order: 2)
        }

        it 'adds the new column at the right column order' do
          expect(new_column.column_order).to eq(2)
        end

        it 'moves the other columns accordingly' do
          expect(first_column.reload.column_order).to eq(1)
          expect(second_column.reload.column_order).to eq(3)
          expect(third_column.reload.column_order).to eq(4)
        end
      end

      # context 'when a new column is moved to an pre-existing column order' do
      #   let!(:board) { create(:board) }
      #   let!(:first_column) { create(:column, board: board) }
      #   let!(:second_column) { create(:column, board: board) }
      #   let!(:third_column) { create(:column, board: board) }

      #   let!(:new_column) {
      #     create(:column, board: board, column_order: 2)
      #   }

      #   before { new_column.update(column_order: 2) }

      #   it 'adds the new column at the right column order' do
      #     expect(new_column.column_order).to eq(2)
      #   end

      #   it 'moves the other columns accordingly' do
      #     expect(first_column.reload.column_order).to eq(1)
      #     expect(second_column.reload.column_order).to eq(3)
      #     expect(third_column.reload.column_order).to eq(4)
      #   end
      # end
    end

      describe '#check_tasks_count' do
        context 'when an column with tasks is being destroyed' do
          let!(:column) { create(:column) }

          before do
           column.tasks << create(:task)
           column.reload.destroy
          end

          it 'does not destroy the record' do
            expect(Column.where(id: column.id)).to exist
          end

          it 'contains an error message' do
            expect(column.errors.messages[:base]).
            to include('Cannot delete record because dependent tasks exist')
          end
        end
      end
  end
end
