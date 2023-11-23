require 'rails_helper'

RSpec.describe "Messages", type: :request do
  let(:user) { create :user }

  describe "GET /index" do
    it_behaves_like 'an authenticated route' do
      let(:request) { get "/users/#{user.id}/messages" }
    end

    it 'returns http success' do
      get "/users/#{user.id}/messages"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/messages/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/messages/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/messages/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/messages/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/messages/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/messages/destroy"
      expect(response).to have_http_status(:success)
    end
  end
end
