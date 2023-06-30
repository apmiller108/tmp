require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create :user }

  describe "GET /show" do
    it_behaves_like 'an API authenticated route' do
      let(:request) { get "/users/#{user.id}.json" }
    end

    it_behaves_like 'an authenticated route' do
      let(:request) { get "/users/#{user.id}" }
    end

    context 'with a JSON format' do
      before do
        get "/users/#{user.id}.json", headers: auth_headers(user)
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end

      it "returns the user JSON" do
        body = JSON.parse(response.body)
        expect(body).to eq({ 'id' => user.id, 'email' => user.email })
      end
    end
  end
end
