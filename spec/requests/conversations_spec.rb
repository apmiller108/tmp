require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  describe 'GET #index' do
    let(:user) { create :user }
    let(:memo) { create :memo, user: }
    let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }
    let!(:conversation) { create :conversation, memo:, user: }

    let(:request) { get "/memos/#{memo.id}/conversations", headers: }

    before do
      sign_in user
    end

    it_behaves_like 'an API authenticated route'

    include_context 'with disable consider all requests local'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end

    it 'returns the memo\'s conversation' do
      request
      expect(response.body).to eq [conversation.attributes.slice('id', 'created_at', 'updated_at')].to_json
    end

    context 'when the conversation does not exist' do
      let(:conversation) { nil }

      it 'returns an empty array' do
        request
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end

  describe 'POST #create' do
    subject { response }

    let(:request) { post "/memos/#{memo.id}/conversations", headers:, params:, as: :json }
    let(:user) { create :user }
    let(:memo) { create :memo, user: }
    let(:generate_text_request) { create :generate_text_request, user: }
    let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }
    let(:params) do
      {
        conversation: {
          assistant_response: 'foo',
          memo_id: memo.id,
          text_id: generate_text_request.text_id
        }
      }
    end

    before do
      sign_in user
    end

    it_behaves_like 'an API authenticated route'

    it 'returns an CREATED response' do
      request
      expect(response).to have_http_status :created
    end

    it 'creates a conversation' do
      expect { request }.to change(Conversation.where(user:, memo:), :count).by(1)
    end

    it 'returns the conversation' do
      request
      conversation = Conversation.last
      expect(response.body).to eq conversation.attributes.slice('id', 'created_at', 'updated_at').to_json
    end
  end

  describe 'PUT #update' do
    subject { response }

    let(:request) { put "/memos/#{memo.id}/conversations/#{conversation.id}", headers:, params:, as: :json }
    let(:user) { create :user }
    let(:memo) { create :memo, user: }
    let(:generate_text_request) { create :generate_text_request, user: }
    let(:conversation) { create :conversation, user:, memo: }
    let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }
    let(:assistant_response) { 'ASSISANT RESPONSE' }
    let(:params) do
      {
        conversation: {
          assistant_response:,
          memo_id: memo.id,
          text_id: generate_text_request.text_id
        }
      }
    end

    before do
      sign_in user
    end

    it_behaves_like 'an API authenticated route'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end

    it 'updates a conversation' do
      expect { request }.to change {
        conversation.reload.exchange.last
      }.to({ 'role' => 'assistant', 'content' => assistant_response })
    end

    it 'returns the conversation' do
      request
      expect(response.body).to eq conversation.reload.attributes.slice('id', 'created_at', 'updated_at').to_json
    end
  end
end
