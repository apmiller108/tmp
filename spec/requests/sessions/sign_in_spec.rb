require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let!(:user) { create :user }
  let(:password) { user.password }

  describe 'POST /users/sign_in.json' do
    before do
      post '/users/sign_in.json', params: { user: { email: user.email, password: password } }
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:success)
    end

    it 'sets the Authorization header' do
      expect(response.headers['Authorization']).not_to be_nil
    end

    context 'with in valid credientials' do
      let(:password) { Faker::Internet.password }

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
