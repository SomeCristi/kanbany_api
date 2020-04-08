require 'rails_helper'

RSpec.describe 'Columns API', type: :request do
  let!(:user) { create(:user) }
  let!(:board) { create(:board, created_by: user) }
  let!(:column_name) { Faker::Lorem.word }
  let!(:column) { create(:column, created_by: user, name: column_name, board: board) }
  let!(:valid_params) do {
    column:
      attributes_for(
        :column,
        board: board,
        created_by: user,
        column_order: column.column_order + 1
      )
  }
  end

  # Column creation test suite
  describe 'POST /boards/:board_id/columns' do
    context 'when valid request' do
      subject { post "/boards/#{board.id}/columns", params: valid_params, headers: valid_headers }

      before do |example|
        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'returns HTTP status 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates a new column', skip_before: true do
        expect{ subject }.to change{ Column.count }.by(1)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(valid_params[:column][:name])
      end

      it 'returns the correct user id' do
        expect(json["created_by_id"]).to eq(user.id)
      end

      it 'return the correct column order' do
        expect(json["column_order"]).to eq(valid_params[:column][:column_order])
      end
    end

    context 'when invalid request' do
      subject { post "/boards/#{board.id}/columns", params: { column: { name: "" } }, headers: valid_headers }

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
        expect{ subject }.not_to change{ Column.count }
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Name can't be blank")
      end
    end

    context 'when unauthorized request' do
      before { post "/boards/#{board.id}/columns", params: valid_params, headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  # Column update test suite
  describe 'PUT /boards/:board_id/columns/:id' do
    context 'when valid request' do
    let!(:second_column) { create(:column, created_by: user, board: board) }
      before { put "/boards/#{board.id}/columns/#{column.id}", params: valid_params, headers: valid_headers }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(valid_params[:column][:name])
      end

      it 'returns the correct order' do
        expect(json["column_order"]).to eq(valid_params[:column][:column_order])
      end

      it 'updates the record' do
        expect(column.reload.name).to eq(valid_params[:column][:name])
      end
    end

    context 'when invalid request' do
      before { put "/boards/#{board.id}/columns/#{column.id}", params: { column: { name: "" } }, headers: valid_headers }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status(422)
      end

      it 'does not update the record' do
        expect(column.reload.name).to eq(column_name)
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Name can't be blank")
      end
    end

    context 'when unauthorized request' do
      before { put "/boards/#{board.id}/columns/#{column.id}", params: valid_params, headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Column show test suite
  describe 'GET /boards/:board_id/columns/:id' do
    context 'when valid request' do
      before { get "/boards/#{board.id}/columns/#{column.id}", headers: valid_headers }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct name' do
        expect(json["name"]).to eq(column.name)
      end

      it 'returns the correct column_order' do
        expect(json["column_order"]).to eq(column.column_order)
      end
    end

    context 'when board does not exist' do
      before { get "/boards/#{board.id}/columns/#{column.id + 100}", headers: valid_headers }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when unauthorized request' do
      before { get "/boards/#{board.id}/columns/#{column.id}", headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Column index test suite
  describe 'GET /boards/:board_id/columns' do
    let!(:second_column) { create(:column, created_by: user, board: board) }
    let!(:column_from_another_board) { create(:column, created_by: user) }

    context 'when valid request' do
      before { get "/boards/#{board.id}/columns", headers: valid_headers }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all the objects' do
        expect(json.size).to eq(2)
      end

      it 'returns all the correct ids' do
        object_ids = [column.id, second_column.id].sort
        response_ids = json.map { |entry| entry['id']}.sort
        expect(response_ids).to eq(object_ids)
      end

      it 'returns all the correct names' do
        object_names = [column.name, second_column.name].sort
        response_names = json.map { |entry| entry['name']}.sort
        expect(response_names).to eq(object_names)
      end

      it 'returns all the correct created_by_ids' do
        created_by_ids = [column.created_by_id, second_column.created_by_id].sort
        expect( json.map { |entry| entry['created_by_id']}.sort).to eq(created_by_ids)
      end

      it 'does not include the columns from another board' do
        ids = json.map { |entry| entry['id']}
        expect(ids).not_to include(column_from_another_board.id)
      end
    end

    context 'when unauthorized request' do
      before { get "/boards/#{board.id}/columns", headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end
end
