require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'Associations' do
    it { should belong_to(:board) }
    it { should belong_to(:user) }
  end

  describe 'Validations' do
    describe 'uniueness of user id scoped to board id' do
      let!(:board) { create(:board) }
      let!(:user) { create(:user) }

      before do
        Membership.create(board_id: board.id, user_id: user.id)
        @membership = Membership.create(board_id: board.id, user_id: user.id)
      end

      it 'validates that user_id - board_id pair is unique' do
        expect(@membership).not_to be_valid
      end

      it 'return an error message' do
        expect(@membership.errors.messages[:user_id]).
          to include('has already been taken')
      end
    end
  end
end
