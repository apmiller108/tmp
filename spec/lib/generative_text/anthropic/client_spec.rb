require 'rails_helper'
require 'faraday'

RSpec.describe GenerativeText::Anthropic::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Write a haiku about a rainy day.' }
  let(:model) { generate_text_request.model }
  let(:temperature) { 0.1 }
  let(:generate_text_request) { create :generate_text_request, :with_anthropic_model, prompt:, temperature: }

  describe '#invoke_model' do
    before do
      create :conversation_turn, turnable: generate_text_request
      stub_anthropic_request(model:, temperature:, prompt:)
    end

    context 'with a valid request' do
      it 'returns an InvokeModelResponse object' do
        response = client.invoke_model(generate_text_request)
        expect(response).to be_a(GenerativeText::Anthropic::InvokeModelResponse)
      end
    end

    context 'with invalid parameters' do
      before do
        stub_anthropic_request(model:, temperature:, prompt:, response_status: 500, response_body: 'Invalid request')
      end

      it 'raises a ClientError exception' do
        expect { client.invoke_model(generate_text_request) }
          .to raise_error(GenerativeText::Anthropic::ClientError, '500: Invalid request')
      end
    end
  end
end
