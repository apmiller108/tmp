require 'rails_helper'
require 'faraday'

RSpec.describe GenerativeText::Anthropic::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Write a haiku about a rainy day.' }
  let(:model) { generate_text_request.model }
  let(:temperature) { 0.1 }
  let(:generate_text_request) { build_stubbed :generate_text_request, :with_anthropic_model, prompt:, temperature: }

  describe '#invoke_model' do
    let(:request_body) do
      { model: model.api_name,
        max_tokens: model.max_tokens,
        system: generate_text_request.system_message,
        temperature:,
        messages: [{ role: 'user',
                     content: [{ type: 'text', text: prompt }] }] }
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
        response = client.invoke_model(generate_text_request)
        expect(response).to be_a(GenerativeText::Anthropic::InvokeModelResponse)
      end
    end

    context 'with invalid parameters' do
      before do
        stub_request(:post, 'https://api.anthropic.com/v1/messages')
          .with(body: request_body).to_return(status: 500, body: 'Invalid request')
      end

      it 'raises a ClientError exception' do
        expect { client.invoke_model(generate_text_request) }
          .to raise_error(GenerativeText::Anthropic::ClientError, '500: Invalid request')
      end
    end
  end
end
