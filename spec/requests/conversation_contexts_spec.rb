require 'rails_helper'

RSpec.describe 'Conversation Contexts', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    subject { response }

    let(:request) { get conversation_contexts_path }

    it_behaves_like 'an authenticated route'

    it 'returns a successful response' do
      request
      expect(response).to be_successful
    end

    it 'displays the conversation contexts' do
      create_list(:conversation_context, 3, user:)
      request
      assert_select 'div[id^="conversation_context_"]', count: 3
    end

    it 'filters by search parameters' do
      create(:conversation_context, user:, filename: 'test_file.pdf', mime_type: 'application/pdf')
      create(:conversation_context, user:, filename: 'another_file.txt', mime_type: 'text/plain')

      get conversation_contexts_path, params: { q: { search: 'pdf' } }
      assert_select 'div[id^="conversation_context_"]', count: 1
      expect(response.body).to include('test_file.pdf')
    end

    it 'paginates results' do
      create_list(:conversation_context, 15, user:)
      get conversation_contexts_path, params: { page: 2, per_page: 5 }
      assert_select 'div[id^="conversation_context_"]', count: 5
    end

    it 'responds to turbo_stream' do
      get conversation_contexts_path, headers: { 'Accept': 'text/vnd.turbo-stream.html' }
      expect(response).to have_turbo_stream(action: 'append', target: 'conversation_contexts')
    end
  end

  describe 'DELETE #destroy' do
    subject { response }

    let(:request) { delete conversation_context_path(conversation_context), headers: }
    let(:headers) { { 'Accept': 'text/vnd.turbo-stream.html' } }
    let!(:conversation_context) { create(:conversation_context, user:) }

    it_behaves_like 'an authenticated route'

    it 'destroys the conversation context' do
      expect do
        request
      end.to change(ConversationContext, :count).by(-1)
    end

    it 'responds with turbo_stream to remove the record' do
      request
      expect(response).to have_turbo_stream(
        action: 'remove', target: "conversation_context_#{conversation_context.id}"
      )
    end

    context 'when authenticated but unauthorized' do
      let(:other_user) { create(:user) }
      let(:conversation_context) { create(:conversation_context, user: other_user) }

      include_context 'with disable consider all requests local'

      it 'returns a not found response' do
        request
        expect(response).to have_http_status(:not_found)
        expect(ConversationContext.exists?(conversation_context.id)).to be true
      end
    end
  end
end
