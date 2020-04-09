require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let!(:user) { create(:user) }
  let!(:board) { create(:board, created_by: user) }
  let!(:column) { create(:column, created_by: user, board: board) }
  let!(:task_title) { Faker::Lorem.word }
  let!(:task) {create(:task, title: task_title, column: column)}
  let!(:valid_params) do {
    task:
      attributes_for(
        :task,
        column: column,
        created_by: user,
        task_order: task.task_order + 1
      )
  }
  end

  # Task creation test suite
  describe 'POST /boards/:board_id/columns/:column_id/tasks' do
    context 'when valid request' do
      subject {
        post "/boards/#{board.id}/columns/#{column.id}/tasks",
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

      it 'creates a new column', skip_before: true do
        expect{ subject }.to change{ Task.count }.by(1)
      end

      it 'returns the correct title' do
        expect(json["title"]).to eq(valid_params[:task][:title])
      end

      it 'returns the correct user id' do
        expect(json["created_by_id"]).to eq(user.id)
      end

      it 'returns the correct task order' do
        expect(json["task_order"]).to eq(valid_params[:task][:task_order])
      end

      it 'returns the correct column id' do
        expect(json["column_id"]).to eq(valid_params[:task][:column][:id])
      end
    end

    context 'when invalid request' do
      subject {
        post "/boards/#{board.id}/columns/#{column.id}/tasks",
        params: { task: { title: "" } },
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
        expect{ subject }.not_to change{ Task.count }
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Title can't be blank")
      end
    end

    context 'when unauthorized request' do
      before { post "/boards/#{board.id}/columns/#{column.id}/tasks", params: valid_params, headers: missing_token_headers }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  # Task update test suite
  describe 'PUT /boards/:board_id/columns/:column_id/tasks/:id' do
    context 'when valid request' do
      let!(:second_task) { create(:task, created_by: user, column: column) }

      before {
        put "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        params: valid_params,
        headers: valid_headers
      }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct title' do
        expect(json["title"]).to eq(valid_params[:task][:title])
      end

      it 'returns the correct order' do
        expect(json["task_order"]).to eq(valid_params[:task][:task_order])
      end

      it 'saves the changes in the DB' do
        task.reload
        expect(task.reload.title).to eq(valid_params[:task][:title])
        expect(task.reload.task_order).to eq(valid_params[:task][:task_order])
      end
    end

    context 'when invalid request' do
      before {
        put "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        params: { task: { title: "" } },
        headers: valid_headers
      }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status(422)
      end

      it 'does not update the record' do
        expect(task.reload.title).to eq(task_title)
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Validation failed: Title can't be blank")
      end
    end

    context 'when unauthorized request' do
      before {
        put "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        params: valid_params,
        headers: missing_token_headers
      }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Task show test suite
  describe 'GET /boards/:board_id/columns/:column_id/tasks/:id' do
    context 'when valid request' do
      before {
        get "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        headers: valid_headers
      }


      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct title' do
        expect(json["title"]).to eq(task.title)
      end

      it 'returns the correct task_order' do
        expect(json["task_order"]).to eq(task.task_order)
      end
    end

    context 'when task does not exist' do
      let(:fake_task_id) { task.id + 100}
      before {
        get "/boards/#{board.id}/columns/#{column.id}/tasks/#{fake_task_id}",
        headers: valid_headers
      }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when unauthorized request' do
      before {
        get "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        headers: missing_token_headers
      }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Task index test suite
  describe 'GET /boards/:board_id/columns/:column_id/tasks' do
    let!(:second_task) { create(:task, created_by: user, column: column) }
    let!(:task_from_another_column) { create(:task, created_by: user) }

    context 'when valid request' do
      before {
        get "/boards/#{board.id}/columns/#{column.id}/tasks",
        headers: valid_headers
      }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all the objects' do
        expect(json.size).to eq(2)
      end

      it 'returns all the correct ids' do
        object_ids = [task.id, second_task.id].sort
        response_ids = json.map { |entry| entry['id']}.sort
        expect(response_ids).to eq(object_ids)
      end

      it 'returns all the correct titles' do
        object_names = [task.title, second_task.title].sort
        response_names = json.map { |entry| entry['title']}.sort
        expect(response_names).to eq(object_names)
      end

      it 'returns all the correct created_by_ids' do
        created_by_ids = [task.created_by_id, second_task.created_by_id].sort
        expect( json.map { |entry| entry['created_by_id']}.sort).to eq(created_by_ids)
      end

      it 'returns all the correct task orders' do
        created_by_ids = [task.reload.task_order, second_task.reload.task_order].sort
        expect( json.map { |entry| entry['task_order']}.sort).to eq(created_by_ids)
      end

      it 'does not include the tasks from another column' do
        ids = json.map { |entry| entry['id']}
        expect(ids).not_to include(task_from_another_column.id)
      end
    end

    context 'when unauthorized request' do
      before {
        get "/boards/#{board.id}/columns/#{column.id}/tasks",
       headers: missing_token_headers
     }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end

  # Task deletion test suite
  describe 'DELETE /boards/:board_id/columns/:column_id/tasks/:id' do
    context 'when valid request' do
      before {
        delete "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        headers: valid_headers
      }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the record' do
        expect(Task.where(id: task.id)).not_to exist
      end

      it 'returns the deleted record' do
        expect(json["title"]).to eq(task.title)
        expect(json["task_order"]).to eq(task.task_order)
        expect(json["column_id"]).to eq(task.column_id)
        expect(json["created_by_id"]).to eq(task.created_by_id)
      end
    end

    context 'when invalid request' do
      let!(:fake_task_id) { task.id + 100 }
      before {
        delete "/boards/#{board.id}/columns/#{column.id}/tasks/#{fake_task_id}",
        headers: valid_headers
      }

      it 'returns HTTP status 422' do
        expect(response).to have_http_status(404)
      end

      it 'does not delete the record' do
        expect(Column.where(id: column.id)).to exist
      end

      it 'returns failure message' do
        expect(json["message"]).to include("Couldn't find Task with 'id'=#{fake_task_id}")
      end
    end

    context 'when unauthorized request' do
      before {
        delete "/boards/#{board.id}/columns/#{column.id}/tasks/#{task.id}",
        headers: missing_token_headers
      }

      it 'returns HTTP status 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json['message']).to match(/Missing token/)
      end
    end
  end
end
