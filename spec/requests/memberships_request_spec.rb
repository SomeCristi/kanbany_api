require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  let!(:user) { create(:user) }
  let!(:board) { create(:board, created_by: user) }
  let(:user2) { create(:user) }
  let!(:valid_params) do
    {
      membership: {
        user_id: user2.id
      }
    }
  end
  describe 'POST /boards/:board_id/memberships' do
    context 'when valid request' do

      subject {
        post "/boards/#{board.id}/memberships",
        params: valid_params,
        headers: valid_headers
      }

      before do |example|
        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'returns HTTP status 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates a new membership', skip_before: true do
        expect{ subject }.to change{ Membership.count }.by(1)
      end

      it 'returns the correct user_id' do
        expect(json["user_id"]).to eq(valid_params[:membership][:user_id])
      end

      it 'returns the correct board_id' do
        expect(json["board_id"]).to eq(board.id)
      end
    end

    context 'when invalid request' do
      let!(:invalid_params) do
      {
        membership: {
          user_id: user.id
        }
      }
      end

      subject {
        post "/boards/#{board.id}/memberships",
        params: invalid_params,
        headers: valid_headers
      }
      before do |example|
        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status(422)
      end

      # does not call subject before
      it 'does not create a new record', skip_before: true do
        expect{ subject }.not_to change{ Membership.count }
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: User has already been taken")
      end
    end

    context 'when unauthorized request' do
      before {
        post "/boards/#{board.id}/memberships",
        params: valid_params,
        headers: missing_token_headers
      }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end
    end

    context "when current user is not a member of the board" do

      subject {
        post "/boards/#{board.id}/memberships",
        params: valid_params,
        headers: valid_headers
      }

      before do |example|
        Membership.where(user_id: user.id, board_id: board.id).first.destroy

        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'returns HTTP status 403' do
        expect(response).to have_http_status(403)
      end

      it 'does not create a new membership', skip_before: true do
        expect{ subject }.not_to change{ Membership.count }
      end
    end
  end
end
