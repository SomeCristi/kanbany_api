require 'rails_helper'

RSpec.describe 'Boards API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { valid_headers }
  let(:valid_params) do
    { board: attributes_for(:board) }
  end

  # Board creation test suite
  describe 'POST /boards' do
    context 'when valid request' do
      # before { post '/boards', params: valid_params, headers: headers }
      subject { post '/boards', params: valid_params, headers: headers }

      it 'returns HTTP status 201' do
        subject
        expect(response).to have_http_status(201)
      end

      it 'creates a new board' do
        expect{ subject }.to change{ Board.count }.by(1)
      end

      it 'returns the correct name' do
        subject
        expect(json["name"]).to eq(valid_params[:board][:name])
      end

      it 'returns the correct user id' do
        subject
        expect(json["created_by_id"]).to eq(user.id)
      end
    end

    context 'when invalid request' do
      before { post '/boards', params: { board: { name: "" } }, headers: headers }

      it 'does not create a new board' do
        expect(response).to have_http_status(422)
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Name can't be blank")
      end
    end
  end
end
