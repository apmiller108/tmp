# frozen_string_literal: true

require 'rails_helper'

describe 'users/sign_out' do
  describe 'POST users/sign_out.json' do
    let(:user) { create :user }
    let!(:jti) { user.jti }

    before do
      post('/users/sign_in.json', params: { user: { email: user.email, password: user.password } })
      bearer_token = response.headers['Authorization']
      headers = {
        'Authorization' => bearer_token,
        'Content-Type' => 'application/json'
      }
      delete '/users/sign_out.json', headers:
    end

    it 'response with no content' do
      expect(response).to have_http_status :no_content
    end

    it 'revokes the user\'s jti' do
      expect(user.reload.jti).not_to eq jti
    end
  end
end
