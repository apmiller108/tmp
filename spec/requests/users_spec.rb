require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create :user }

  describe "GET /show" do
    before { get "users/#{user.id}.json" }

    xit "returns a successful response" do
      expect(response).to have_http_status(:success)
    end

    xit "returns the user with id 1 in JSON format" do
      user = JSON.parse(response.body)
      expect(user).to contain_exactly id: user.id, email: user.email
    end
  end
end
