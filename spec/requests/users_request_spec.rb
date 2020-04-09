require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { build(:user) }
  let(:headers) { valid_headers.except('Authorization') }
  let(:valid_attributes) do
    {
      user:
        attributes_for(:user, password_confirmation: user.password)
    }
  end

  # User signup test suite
  describe 'POST /signup' do
    context 'when valid request' do

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
end
