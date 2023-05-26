require 'rails_helper'

RSpec.describe 'users/sign_in', type: :request do
  let!(:user) { create :user }
  let(:password) { user.password }

  describe 'POST /users/sign_in.json' do
    before do
      post '/users/sign_in.json', params: { user: { email: user.email, password: password } }
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end

    it 'sets the Authorization header' do
      expect(response.headers['Authorization']).not_to be_nil
    end

    it 'returns the user JSON' do
      expect(JSON.parse(response.body)).to eq user.as_json(only: %i[email id])
    end

    context 'with invalid credientials' do
      let(:password) { Faker::Internet.password }

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /users/sign_in' do
    before do
      post '/users/sign_in', params: { user: { email: user.email, password: password } }
    end

    it { is_expected.to redirect_to "/" }

    it 'shows a success message' do
      expect(flash[:notice]).to eq 'Signed in successfully.'
    end

    context 'with invalid credientials' do
      let(:password) { Faker::Internet.password }

      it 'shows an error message' do
        expect(flash[:alert]).to eq 'Invalid Email or password.'
      end
    end
  end
end
