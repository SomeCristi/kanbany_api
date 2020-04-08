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
      subject { post '/boards', params: valid_params, headers: headers }

      # calls subject before all examples that do not use
      # skip_before: true
      before do |example|
        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'returns HTTP status 201' do
        expect(response).to have_http_status(201)
      end

      # does not call subject before
      it 'creates a new board', skip_before: true do
        expect{ subject }.to change{ Board.count }.by(1)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(valid_params[:board][:name])
      end

      it 'returns the correct user id' do
        expect(json["created_by_id"]).to eq(user.id)
      end

      it 'adds the creator as a member' do
        board = Board.find(json["id"])
        expect(board.users.pluck(:id)).to include(user.id)
      end
    end

    context 'when invalid request' do
      subject { post '/boards', params: { board: { name: "" } }, headers: headers }

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
        expect{ subject }.not_to change{ Board.count }
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Name can't be blank")
      end
    end
  end

  # Board update test suite
  describe 'PUT /boards/:id' do
    let(:board_name) { Faker::Lorem.word }
    # the board is created by the user because he will be added
    # as a member automatically
    let(:board) { create(:board, created_by: user, name: board_name) }

    context 'when valid request' do
      before { put "/boards/#{board.id}", params: valid_params, headers: headers }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(valid_params[:board][:name])
      end

      it 'updates the record' do
        expect(board.reload.name).to eq(valid_params[:board][:name])
      end
    end

    context 'when invalid request' do
      before { put "/boards/#{board.id}", params: { board: { name: "" } }, headers: headers }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status(422)
      end

      it 'does not update the record' do
        expect(board.reload.name).to eq(board_name)
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Name can't be blank")
      end
    end

    context 'when unauthorized request' do
      before { put "/boards/#{board.id}", params: valid_params, headers: missing_token_headers }

      it 'returns HTTP status 401' do
        # binding.pry
        expect(response).to have_http_status(401)
      end
    end
  end
end
