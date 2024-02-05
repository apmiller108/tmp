require 'rails_helper'

RSpec.describe 'Generative Texts', type: :request do
  describe 'POST #create' do
    let(:user) { create :user }
    let(:generative_text) { instance_double GenerativeText }
    let(:prompt) { 'list all the flavors of quarks' }
    let(:params) { { generative_text: { input: prompt, text_id: 1 } } }
    let(:model_response) { instance_double(GenerativeText::AWS::Client::InvokeModelResponse, content: 'Generated text') }
    let(:request) do
      post generative_texts_path, params:, as: :turbo_stream
    end

    before do
      allow(GenerativeText).to receive(:new).and_return(generative_text)
      allow(generative_text).to(
        receive(:invoke_model).with(prompt:, temp: 0.3, max_tokens: 500).and_return(model_response)
      )
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with a turbo stream format' do
      context 'when GenerativeText returns a response' do
        before { request }

        it 'returns a successful response' do
          expect(response).to have_http_status(:created)
        end

        it 'renders the turbo stream with generated content' do
          expect(response.body).to include model_response.content
        end
      end

      context 'when GenerativeText raises an error' do
        before do
          allow(generative_text).to receive(:invoke_model).and_raise 'Error generating text'
          request
        end

        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it { is_expected.to have_turbo_stream(action: :update, target: 'alert-stream') }
      end
    end
  end
end
