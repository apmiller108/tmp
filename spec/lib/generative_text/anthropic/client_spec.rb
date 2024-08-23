require 'rails_helper'
require 'faraday'

RSpec.describe GenerativeText::Anthropic::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Write a haiku about a rainy day.' }
  let(:messages) { [] }
  let(:params) { { temperature: 0.7, system_message: 'this is the system message' } }

  describe '#invoke_model' do
    let(:model) { GenerativeText::Anthropic::DEFAULT_MODEL }
    let(:request_body) do
      { model: model.api_name,
        max_tokens: model.max_tokens,
        system: params[:system_message],
        temperature: params[:temperature],
        messages: [{ role: 'user',
                     content: [{ type: 'text', text: 'Write a haiku about a rainy day.' }] }] }
    end

    before do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .with(
          body: request_body,
          headers: {
            'Anthropic-Version' => '2023-06-01',
            'Content-Type' => 'application/json',
            'X-Api-Key' => 'anthropic_key'
          }
        ).to_return(status: 200, body: {}.to_json, headers: {})
    end

    context 'with a valid request' do
      it 'returns an InvokeModelResponse object' do
        response = client.invoke_model(prompt:, messages:, **params)
        expect(response).to be_a(GenerativeText::Anthropic::InvokeModelResponse)
      end

      context 'with the model param' do
        let(:model) { GenerativeText::Anthropic::MODELS.fetch(:sonnet35) }
        let(:params) { { temperature: 0.7, system_message: 'this is the system message', model: 'sonnet35' } }

        it 'returns an InvokeModelResponse object' do
          response = client.invoke_model(prompt:, messages:, **params)
          expect(response).to be_a(GenerativeText::Anthropic::InvokeModelResponse)
        end
      end
    end

    context 'with invalid parameters' do
      before do
        stub_request(:post, 'https://api.anthropic.com/v1/messages')
          .with(body: request_body).to_return(status: 500, body: 'Invalid request')
      end

      it 'raises a ClientError exception' do
        expect { client.invoke_model(prompt:, messages:, **params) }
          .to raise_error(GenerativeText::Anthropic::ClientError, '500: Invalid request')
      end
    end
  end
end
