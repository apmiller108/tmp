require 'rails_helper'

RSpec.describe 'Conversation Contexts Conversations', type: :request do
  subject { response }

  let(:user) { create :user }
  let(:conversation) { create :conversation, user: }
  let(:params) { {} }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let(:request) { get conversation_conversation_contexts_conversations_path(conversation) }

    it_behaves_like 'an authenticated route'

    context 'when the request is made' do
      before do
        create(:conversation_contexts_conversation, conversation:)
        request
      end

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #create' do
    let(:request) do
      post conversation_conversation_contexts_conversations_path(conversation), params:, as: :turbo_stream
    end
    let(:context1) { create :conversation_context, user: }
    let(:context2) { create :conversation_context, user: }

    it_behaves_like 'an authenticated route'

    context 'with existing context IDs' do
      let(:params) do
        {
          conversation_context: {
            conversation_context_ids: [context1.id, context2.id]
          }
        }
      end

      it 'creates new conversation_contexts_conversations' do
        expect { request }.to change(ConversationContextsConversation, :count).by(2)
      end

      describe 'response' do
        before { request }

        it { is_expected.to have_http_status(:ok) }

        it { is_expected.to have_turbo_stream(action: :prepend, target: 'conversation-context-list', count: 2) }
        it { is_expected.to have_turbo_stream(action: :remove, target: context1) }
        it { is_expected.to have_turbo_stream(action: :remove, target: context2) }
      end
    end

    context 'with a new file upload' do
      let(:file) { fixture_file_upload('test_file.txt', 'text/plain') }
      let(:anthropic_response) do
        instance_double(Anthropic::FileResponse, id: 'file123',
                                                 filename: 'test.txt',
                                                 created_at: Time.current,
                                                 mime_type: 'text/plain')
      end
      let(:params) do
        {
          conversation_context: {
            file:
          }
        }
      end

      before do
        allow(Anthropic).to receive(:upload_file).and_return(anthropic_response)
        allow(DeleteRemoteConversationContextJob).to receive(:perform_async)
      end

      it 'creates a new ConversationContext and attaches it' do
        expect { request }.to change(ConversationContext, :count).by(1)
                                                                 .and change(ConversationContextsConversation,
                                                                             :count).by(1)
      end

      context 'when request is made' do
        before { request }

        let(:new_context) { ConversationContext.last }

        it { is_expected.to have_http_status(:ok) }

        it { is_expected.to have_turbo_stream(action: :prepend, target: 'conversation-context-list') }
        it { is_expected.to have_turbo_stream(action: :remove, target: new_context) }
      end

      context 'when ConversationContext creation fails due to invalid ' do
        let(:anthropic_response) do
          instance_double(Anthropic::FileResponse, id: 'file123',
                                                   filename: nil,
                                                   created_at: Time.current,
                                                   mime_type: 'text/plain')
        end

        before { request }

        it 'enqueues a job to delete the remote file' do
          expect(DeleteRemoteConversationContextJob).to have_received(:perform_async).with('file123')
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end

    context 'with invalid parameters' do
      let(:params) { { conversation_context: { conversation_context_ids: [''] } } }

      it 'does not create a new record' do
        expect { request }.not_to change(ConversationContextsConversation, :count)
      end

      context 'when request is made' do
        before { request }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'sets a flash alert' do
          expect(flash.now[:alert]).to eq('Unable to create context')
        end
      end
    end
  end
end
