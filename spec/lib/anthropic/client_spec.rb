require 'rails_helper'

RSpec.describe Anthropic::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Write a haiku about a rainy day.' }
  let(:model) { generate_text_request.model }
  let(:temperature) { 0.1 }
  let(:generate_text_request) { create :generate_text_request, :with_anthropic_model, prompt:, temperature: }

  describe '#invoke_model' do
    context 'with a valid request' do
      context 'with a conversation' do
        let!(:http_request) do
          stub_anthropic_messages_request(model:, temperature:, prompt:)
        end

        before do
          create :conversation_turn, turnable: generate_text_request,
                                     conversation: create(:conversation, tool_types: ['image'])
        end

        it 'calls the messages endpoint' do
          client.invoke_model(generate_text_request)
          expect(http_request).to have_been_requested
        end

        it 'returns an InvokeModelResponse object' do
          response = client.invoke_model(generate_text_request)
          expect(response).to be_a(Anthropic::InvokeModelResponse)
        end
      end

      context 'without a conversation' do
        let!(:http_request) do
          stub_anthropic_messages_request(model:, temperature:, prompt:, tools: nil, tool_choice: nil)
        end

        it 'calls the messages endpoint without conversation dependent options' do
          client.invoke_model(generate_text_request)
          expect(http_request).to have_been_requested
        end
      end
    end

    context 'with invalid parameters' do
      before do
        create :conversation_turn, turnable: generate_text_request,
                                   conversation: create(:conversation, tool_types: ['image'])
        stub_anthropic_messages_request(
          model:, temperature:, prompt:, response_status: 500, response_body: 'Invalid request'
        )
      end

      it 'raises a UnknownError exception' do
        expect { client.invoke_model(generate_text_request) }
          .to raise_error(Anthropic::ServerError, 'No error message from server')
      end
    end
  end

  describe '#invoke_model_stream' do
    subject(:client) { described_class.new }

    let(:generate_text_request) { build_stubbed :generate_text_request }
    let(:invoke_model_request) do
      instance_double(Anthropic::InvokeModelRequest, to_json: '{"request":"data"}')
    end
    let(:stream_response) do
      instance_double(Anthropic::StreamResponse, update: nil, to_response_format: response_format)
    end
    let(:response_format) { { 'response' => 'data' } }

    before do
      allow(Anthropic::InvokeModelRequest).to receive(:new).with(generate_text_request, stream: true)
                                                           .and_return(invoke_model_request)
      allow(Anthropic::StreamResponse).to receive(:new).and_return(stream_response)
      allow(Anthropic::InvokeModelResponse).to receive(:new).with(response_format)
                                                            .and_return('final_response')

      allow(Anthropic::StreamEvent).to receive(:parse).and_call_original

      stub_request(:post, "#{Anthropic::HOST}#{Anthropic::MESSAGES_PATH}")
        .with(
          body: '{"request":"data"}',
          headers: {
            'Content-Type' => 'application/json',
            'anthropic-version' => Anthropic::VERSION,
            'x-api-key' => ENV.fetch('ANTHROPIC_KEY')
          }
        )
        .to_return(
          status: 200,
          body: file_fixture('anthropic/messages_stream_response.txt'),
          headers: { 'Content-Type' => 'text/event-stream' }
        )
    end

    it 'yields text content from stream events' do
      chunks = []
      client.invoke_model_stream(generate_text_request) { |chunk| chunks << chunk }

      expect(chunks).to eq(['test', ' assistant', ' response'])
    end

    it 'returns the final, complete response' do
      result = client.invoke_model_stream(generate_text_request) {}
      expect(result).to eq('final_response')
    end

    it 'parses the SSE events' do
      client.invoke_model_stream(generate_text_request) {}
      expect(Anthropic::StreamEvent).to have_received(:parse).exactly(8).times
    end

    it 'updates the stream response with all event other than ping' do
      client.invoke_model_stream(generate_text_request) {}
      expect(stream_response).to have_received(:update).with(kind_of(Anthropic::StreamEvent))
                                                       .exactly(7).times
    end

    context 'when a 400 error occurs' do
      before do
        stub_request(:post, "#{Anthropic::HOST}#{Anthropic::MESSAGES_PATH}")
          .to_return(status: 400, body: '')
      end

      it 'raises a ClientError' do
        expect { client.invoke_model_stream(generate_text_request) {} }
          .to raise_error(Anthropic::ClientError, /: Check request body:/)
      end
    end
  end
end
