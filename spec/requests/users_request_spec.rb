require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  # User signup test suite
  describe 'POST /signup' do
    let(:user) { build(:user) }
    let(:headers) { valid_headers.except('Authorization') }

    context 'when valid request' do
      let(:valid_attributes) do
        {
          user:
            attributes_for(:user, password_confirmation: user.password)
        }
      end

      subject { post '/signup', params: valid_attributes, headers: headers }

      before do |example|
        unless example.metadata[:skip_before]
          subject
        end
      end

      it 'ceturns HTTP status 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates a new user', skip_before: true do
        expect{ subject }.to change{ User.count }.by(1)
      end

      it 'returns an authentication token' do
        expect(json['auth_token']).not_to be_nil
      end
    end

    context 'when invalid request' do
      before { post '/signup', params: { user: attributes_for(:user, password: "")  }, headers: headers }

      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end

      it 'returns failure message' do
        expect(json['message'])
          .to include("Validation failed: Password can't be blank")
      end
    end
  end

  # User change role test suite
  describe 'PUT /change_role' do
    let(:user) { create(:user) }
    let!(:another_user) { create(:user, role: :normal) }
    context 'when valid request' do
      let(:valid_attributes) do
        {
          user: {
            role: "developer"
          }
        }
      end

      subject { put "/users/#{another_user.id}/change_role", params: valid_attributes, headers: valid_headers }

      before do
        subject
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'changes the role' do
        expect(another_user.reload.role).to eq(valid_attributes[:user][:role])
      end
    end

    context 'when invalid request' do
      let(:invalid_attributes) do
        {
          user: {
            role: ""
          }
        }
      end

      before {
        put "/users/#{another_user.id}/change_role",
        params: invalid_attributes,
        headers: valid_headers
      }

      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end

      it 'returns failure message' do
        expect(json['message'])
          .to include("Validation failed: Role can't be blank")
      end
    end
  end
end
