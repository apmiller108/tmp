require 'rails_helper'

RSpec.describe LLMService::AWS::Client::EventStreamHandler do
  describe '#initialize' do
    it 'stores the block' do
      block = proc { |event| puts event }
      handler = described_class.new(&block)

      expect(handler.instance_variable_get(:@block)).to eq(block)
    end
  end

  describe '#to_proc' do
    it 'returns a proc with event handlers' do
      block = proc { |event| puts event }
      handler = described_class.new(&block)

      proc_result = handler.to_proc
      expect(proc_result).to be_a(Proc)
    end
  end

  describe '#on_chunk_event' do
    it 'calls the provided block with the event' do
      bytes = double
      event = instance_double(Aws::BedrockRuntime::Types::PayloadPart, bytes:)
      response = instance_double(LLMService::AWS::Client::InvokeModelStreamResponse)
      allow(LLMService::AWS::Client::InvokeModelStreamResponse).to receive(:new).with(bytes).and_return(response)
      block = proc { |e| e }
      handler = described_class.new(&block)

      expect(block).to receive(:call).with(response)
      handler.on_chunk_event(event)
    end
  end

  describe '#on_exception' do
    it 'raises InvalidRequestError with the correct message' do
      handler = described_class.new {}
      event = OpenStruct.new({ 'event_type' => 'some_event', 'message' => 'Some error message' })

      expect { handler.on_exception(event) }.to(
        raise_error(LLMService::InvalidRequestError, 'some_event: Some error message')
      )
    end
  end

  describe '#on_model_stream_error' do
    it 'raises InvalidRequestError with the correct message' do
      handler = described_class.new {}
      event = OpenStruct.new({ 'event_type' => 'model_stream_error',
                               'message' => 'Model stream error',
                               'original_message' => 'Original message' })

      expect { handler.on_model_stream_error(event) }.to(
        raise_error(LLMService::InvalidRequestError, 'model_stream_error: Model stream error : Original message')
      )
    end
  end

  describe '#on_generic_error' do
    it 'raises InvalidRequestError with the correct message' do
      handler = described_class.new {}
      event = OpenStruct.new({ 'event_type' => 'generic_error',
                               'error_code' => 'ERROR_CODE',
                               'error_message' => 'Error message' })

      expect { handler.on_generic_error(event) }.to(
        raise_error(LLMService::InvalidRequestError, 'generic_error: ERROR_CODE : Error message')
      )
    end
  end
end
