require 'rails_helper'

RSpec.describe GenerativeText::AWS::Client::InvokeModelResponse do
  subject(:response) { described_class.new(json_response) }

  let(:content) { Faker::Lorem.paragraph }
  let(:json_response) do
    <<~JSON
      {
        "inputTextTokenCount": 5,
        "results": [
          {
            "tokenCount": 55,
            "outputText": "#{content}",
            "completionReason": "FINISH"
          }
        ]
      }
    JSON
  end

  describe '#content' do
    it 'returns the output text from the response' do
      expect(response.content).to eq(content)
    end
  end

  describe '#results' do
    it 'returns the results from the response' do
      expected_results = {
        'tokenCount' => 55,
        'outputText' => content,
        'completionReason' => 'FINISH'
      }

      expect(response.results).to eq(expected_results)
    end
  end

  describe '#completion_reason' do
    it 'returns the completion reason from the results' do
      expect(response.completion_reason).to eq('FINISH')
    end
  end

  describe '#token_count' do
    it 'calculates the total token count from input and output tokens' do
      expect(response.token_count).to eq(60) # (5 input tokens) + (55 output tokens)
    end
  end
end
