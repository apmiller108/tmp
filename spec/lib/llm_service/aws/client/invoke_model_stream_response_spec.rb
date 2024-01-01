require 'rails_helper'

RSpec.describe LLMService::AWS::Client::InvokeModelStreamResponse do
  let(:input_token_count) { 9 }
  let(:output_token_count) { 104 }
  let(:data) do
    {
      'outputText' => 'final part of stream',
      'index' => 0,
      'completionReason' => 'FINISH',
      'inputTextTokenCount' => nil,
      'amazon-bedrock-invocationMetrics' => {
        'inputTokenCount' => input_token_count,
        'outputTokenCount' => output_token_count,
        'invocationLatency' => 3407,
        'firstByteLatency' => 2440
      }
    }
  end
  let(:json) { data.to_json }

  describe '#initialize' do
    it 'parses valid JSON and stores it' do
      response = described_class.new(json)
      expect(response.response_data).to eq(JSON.parse(json))
    end
  end

  describe '#content' do
    it 'returns the output text' do
      response = described_class.new(json)
      expect(response.content).to eq(data['outputText'])
    end
  end

  describe '#final_chunk?' do
    it 'returns true if completionReason is present' do
      response = described_class.new(json)
      expect(response).to be_final_chunk
    end

    it 'returns false if completionReason is not present' do
      data['completionReason'] = nil
      response = described_class.new(json)
      expect(response).not_to be_final_chunk
    end
  end

  describe '#token_count' do
    it 'returns the sum of inputTokenCount and outputTokenCount from metrics' do
      response = described_class.new(json)
      expect(response.token_count).to eq(input_token_count + output_token_count)
    end

    it 'returns 0 if metrics are not present' do
      data.delete('amazon-bedrock-invocationMetrics')
      response = described_class.new(json)
      expect(response.token_count).to eq(0)
    end
  end
end
