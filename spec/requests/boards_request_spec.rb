require 'rails_helper'

RSpec.describe 'Boards API', type: :request do
  let(:user) { create(:user) }
  let(:valid_params) do
    { board: attributes_for(:board) }
  end
  let(:board_name) { Faker::Lorem.word }
  # the board is created by the user because he will be added
  # as a member automatically
  # let! is used insead of let because in the GET boards test the
  # objects were not persisted to the DB
  # explanation here: https://relishapp.com/rspec/rspec-core/v/3-5/docs/helper-methods/let-and-let
  let!(:board) { create(:board, created_by: user, name: board_name) }
  let!(:not_a_member_board) { create(:board) }

  # Board creation test suite
  describe 'POST /boards' do
    context 'when valid request' do
      subject { post '/boards', params: valid_params, headers: valid_headers }

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
      subject { post '/boards', params: { board: { name: "" } }, headers: valid_headers }

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

    context 'when unauthorized request' do
      before { post "/boards", params: valid_params, headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  # Board update test suite
  describe 'PUT /boards/:id' do
    context 'when valid request' do
      before { put "/boards/#{board.id}", params: valid_params, headers: valid_headers }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(valid_params[:board][:name])
      end

      it 'saves the changes in the DB' do
        expect(board.reload.name).to eq(valid_params[:board][:name])
      end
    end

    context 'when invalid request' do
      before { put "/boards/#{board.id}", params: { board: { name: "" } }, headers: valid_headers }

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
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end

    context 'when user is not a member' do
      before { put "/boards/#{not_a_member_board.id}", params: valid_params, headers: valid_headers }

      it 'returns HTTP status 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Board show test suite
  describe 'GET /boards/:id' do
    context 'when valid request' do
      before { get "/boards/#{board.id}", headers: valid_headers }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(board.name)
      end
    end

    context 'when board does not exist' do
      before { get "/boards/#{board.id + 100}", headers: valid_headers }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when user is not a member' do
      before { get "/boards/#{not_a_member_board.id}", headers: valid_headers }

      it 'returns HTTP status 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when unauthorized request' do
      before { get "/boards/#{board.id}", headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Board index test suite
  describe 'GET /boards' do
    let!(:second_board) { create(:board, created_by: user) }

    context 'when valid request' do
      before { get "/boards", headers: valid_headers }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all the objects' do
        expect(json.size).to eq(2)
      end

      it 'does not include the boards that the user is not a member of' do
        ids = json.map { |entry| entry['id']}
        expect(ids).not_to include(not_a_member_board.id)
      end

      it 'returns all the correct ids' do
        objects_id = [board.id, second_board.id].sort
        response_ids = json.map { |entry| entry['id']}.sort
        expect(response_ids).to eq(objects_id)
      end

      it 'returns all the correct names' do
        objects_name = [board.name, second_board.name].sort
        response_names = json.map { |entry| entry['name']}.sort
        expect(response_names).to eq(objects_name)
      end

      it 'returns all the correct created_by_ids' do
        created_by_ids = [board.created_by_id, second_board.created_by_id].sort
        expect( json.map { |entry| entry['created_by_id']}.sort).to eq(created_by_ids)
      end
    end

    context 'when unauthorized request' do
      before { get "/boards", headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end
end
