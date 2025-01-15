require 'rails_helper'

RSpec.describe 'Generate text requests', type: :request do
  describe 'POST #create' do
    let(:user) { create :user, :with_setting }
    let(:prompt) { 'list all the flavors of quarks' }
    let(:text_id) { 'abcd' }
    let(:conversation) { create :conversation, user: }
    let(:generate_text_preset) { create :generate_text_preset }
    let(:temperature) { 0.5 }
    let(:params) do
      {
        generate_text_request: {
          prompt:, text_id:, temperature:,
          generate_text_preset_id: generate_text_preset.id, conversation_id: conversation.id
        }
      }
    end
    let(:request) do
      post generate_text_requests_path, params:, as: :turbo_stream
    end

    before do
      allow(GenerateTextJob).to receive(:perform_async)
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with a turbo stream format' do
      context 'with a valid request' do
        it 'returns a successful response' do
          request
          expect(response).to have_http_status(:created)
        end

        it 'returns an empty body' do
          request
          expect(response.body).to be_empty
        end

        it 'creates a generate_text_requests record' do
          expect { request }.to(
            change(
              user.generate_text_requests.where(
                prompt:, text_id:, conversation:, generate_text_preset:, conversation_id: conversation.id
              ),
              :count
            ).by(1)
          )
        end

        it 'enqueues a GenerateTextJob' do
          request
          expect(GenerateTextJob).to have_received(:perform_async).with(user.generate_text_request_ids.last)
        end

        context 'without a conversation id' do
          let(:params) do
            {
              generate_text_request: {
                prompt:, text_id:, temperature:,
                generate_text_preset_id: generate_text_preset.id, conversation_id: ''
              }
            }
          end

          it 'creates a conversation' do
            expect { request }.to change(user.conversations, :count).by(1)
          end
        end
      end

      context 'when the request is invalid' do
        let(:params) { { generate_text_request: { input: nil, text_id: nil } } }

        before { request }

        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it { is_expected.to have_turbo_stream(action: :update, target: 'alert-stream') }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create :user, :with_setting }
    let!(:generate_text_request) { create :generate_text_request, user: }

    let(:request) do
      delete generate_text_request_path(generate_text_request), as: :turbo_stream
    end

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'delete the generate_text_request' do
      expect { request }.to change(user.generate_text_requests, :count).by(-1)
    end

    it 'responds with OK' do
      request
      expect(response).to have_http_status :ok
    end

    it 'removes the element' do
      request
      expect(response).to have_turbo_stream(action: :remove, target: generate_text_request)
    end
  end
end
