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

  describe '#invoke_model_stream' do
    subject(:client) { described_class.new }

    let(:generate_text_request) { build_stubbed :generate_text_request }
    let(:invoke_model_request) do
      instance_double(GenerativeText::Anthropic::InvokeModelRequest,to_json: '{"request":"data"}')
    end
    let(:stream_response) do
      instance_double(GenerativeText::Anthropic::StreamResponse, update: nil, to_response_format: response_format)
    end
    let(:response_format) { { 'response' => 'data' } }

    before do
      allow(GenerativeText::Anthropic::InvokeModelRequest).to receive(:new).with(generate_text_request, stream: true)
                                                                           .and_return(invoke_model_request)
      allow(GenerativeText::Anthropic::StreamResponse).to receive(:new).and_return(stream_response)
      allow(GenerativeText::Anthropic::InvokeModelResponse).to receive(:new).with(response_format)
                                                                            .and_return('final_response')

      allow(GenerativeText::Anthropic::StreamEvent).to receive(:parse).and_call_original

      stub_request(:post, "#{GenerativeText::Anthropic::HOST}#{GenerativeText::Anthropic::MESSAGES_PATH}")
        .with(
          body: '{"request":"data"}',
          headers: {
            'Content-Type' => 'application/json',
            'anthropic-version' => GenerativeText::Anthropic::VERSION,
            'x-api-key' => Rails.application.credentials.fetch(:anthropic_key)
          }
        )
        .to_return(
          status: 200,
          body: <<~BODY,
            event: message_start
            data: {"type": "message_start", "message": {"id": "msg_1nZdL29xx5MUA1yADyHTEsnR8uuvGzszyY", "type": "message", "role": "assistant", "content": [], "model": "claude-3-7-sonnet-20250219", "stop_reason": null, "stop_sequence": null, "usage": {"input_tokens": 25, "output_tokens": 1}}}

            event: content_block_start
            data: {"type": "content_block_start", "index": 0, "content_block": {"type": "text", "text": "chunk1"}}

            event: ping
            data: {"type": "ping"}

            event: content_block_delta
            data: {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": "chunk2"}}

            event: content_block_delta
            data: {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": "chunk3"}}

            event: content_block_stop
            data: {"type": "content_block_stop", "index": 0}

            event: message_delta
            data: {"type": "message_delta", "delta": {"stop_reason": "end_turn", "stop_sequence":null}, "usage": {"output_tokens": 15}}

            event: message_stop
            data: {"type": "message_stop"}
          BODY
          headers: { 'Content-Type' => 'text/event-stream' }
        )
    end

    it 'yields text content from stream events' do
      chunks = []
      client.invoke_model_stream(generate_text_request) { |chunk| chunks << chunk }

      expect(chunks).to eq(%w[chunk1 chunk2 chunk3])
    end

    it 'returns the final, complete response' do
      result = client.invoke_model_stream(generate_text_request) {}
      expect(result).to eq('final_response')
    end

    it 'parses the SSE events' do
      client.invoke_model_stream(generate_text_request) {}
      expect(GenerativeText::Anthropic::StreamEvent).to have_received(:parse).exactly(8).times
    end

    it 'updates the stream response with all event other than ping' do
      client.invoke_model_stream(generate_text_request) {}
      expect(stream_response).to have_received(:update).with(kind_of(GenerativeText::Anthropic::StreamEvent)).exactly(7).times
    end

    context 'when an error occurs' do
      before do
        stub_request(:post, "#{GenerativeText::Anthropic::HOST}#{GenerativeText::Anthropic::MESSAGES_PATH}")
          .to_return(status: 400, body: '')
      end

      it 'raises a ClientError with status and body' do
        expect { client.invoke_model_stream(generate_text_request) {} }
          .to raise_error(GenerativeText::Anthropic::ClientError)
      end
    end
  end
end
