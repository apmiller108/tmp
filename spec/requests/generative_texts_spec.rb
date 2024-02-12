require 'rails_helper'

RSpec.describe 'Generative Texts', type: :request do
  describe 'POST #create' do
    let(:user) { create :user }
    let(:prompt) { 'list all the flavors of quarks' }
    let(:params) { { generate_text_request: { prompt:, text_id: 1 } } }
    let(:request) do
      post generate_text_requests_path, params:, as: :turbo_stream
    end

    before do
      allow(GenerateTextJob).to receive(:perform_async)
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with a turbo stream format' do
      context 'when GenerativeText returns a response' do
        it 'returns a successful response' do
          request
          expect(response).to have_http_status(:created)
        end

        it 'renders the turbo stream with generated content' do
          request
          expect(response.body).to be_empty
        end

        it 'creates a generate_text_requests record' do
          expect { request }.to change(user.generate_text_requests, :count).by(1)
        end

        it 'enqueues a GenerateTextJob' do
          request
          expect(GenerateTextJob).to have_received(:perform_async).with(user.generate_text_request_ids.last)
        end
      end

      context 'when the GenerateTextRequest is invalid' do
        let(:params) { { generate_text_request: { input: nil, text_id: nil } } }

        before { request }

        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it { is_expected.to have_turbo_stream(action: :update, target: 'alert-stream') }
      end
    end
  end
end
