require 'spec_helper'

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
          "output_tokens": 942
        }
      }
    JSON
  end

  let(:response) { described_class.new(json_response) }

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
      expect(response.token_count).to eq(1021)
    end
  end
end
