require 'rails_helper'

RSpec.describe GenerativeText::Anthropic::InvokeModelResponse do
  let(:json_response) do
    <<~JSON
      {
        "id": "msg_01DMcCdRr6gaWDuZs7Y63rhe",
        "type": "message",
        "role": "assistant",
        "content": [
          {
            "type": "text",
            "text": "response content goes here"
          }
        ],
        "model": "claude-3-haiku-20240307",
        "stop_reason": "end_turn",
        "stop_sequence": null,
        "usage": {
          "input_tokens": 79,
          "output_tokens": 942,
          "cache_creation_input_tokens": 1,
          "cache_read_input_tokens": 100
        }
      }
    JSON
  end

  let(:response) { described_class.new(json_response) }

  describe '#initialize' do
    context 'when initialized with JSON' do
      it 'parses the JSON' do
        data = described_class.new(json_response).data
        expect(data).to eq JSON.parse(json_response)
      end
    end

    context 'when initialized with a Hash' do
      it 'does not attempt JSON parsing' do
        json_hash = JSON.parse(json_response)
        data = described_class.new(json_hash).data
        expect(data).to eq json_hash
      end
    end
  end

  describe '#content' do
    it 'returns the text content of the response' do
      expect(response.content).to eq('response content goes here')
    end
  end

  describe '#results' do
    it 'returns the content array from the response' do
      expect(response.results).to eq([
                                       { 'type' => 'text', 'text' => 'response content goes here' }
                                     ])
    end
  end

  describe '#completion_reason' do
    it 'returns the stop_reason from the response' do
      expect(response.completion_reason).to eq('end_turn')
    end
  end

  describe '#token_count' do
    it 'returns the total number of input and output tokens' do
      expect(response.token_count).to eq(1122)
    end
  end
end
