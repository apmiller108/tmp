require 'rails_helper'

RSpec.describe 'Conversation turns', type: :request do
  describe 'DELETE #destroy' do
    let!(:conversation_turn) { create :conversation_turn, conversation:, turnable: generate_text_request }
    let(:user) { create :user, :with_setting }
    let(:conversation) { create :conversation, user: }
    let(:generate_text_request) { create :generate_text_request, user: }

    let(:request) do
      delete conversation_conversation_turn_path(conversation, conversation_turn), as: :turbo_stream
    end

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'delete the generate_text_request' do
      expect { request }.to change(conversation.turns, :count).by(-1)
    end

    it 'responds with OK' do
      request
      expect(response).to have_http_status :ok
    end

    it 'removes the element' do
      request
      expect(response).to have_turbo_stream(action: :remove, target: conversation_turn)
    end
  end
end
