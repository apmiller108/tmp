require 'rails_helper'

RSpec.describe Gemini::InvokeModelResponse do
  let(:response_body) do
    {
      candidates: [
        {
          content: {
            parts: [{ text: 'Response text' }]
          }
        }
      ],
      usageMetadata: {
        promptTokenCount: 10,
        candidatesTokenCount: 20
      }
    }.to_json
  end

  subject { described_class.new(response_body) }

  describe '#content' do
    it 'returns the text content' do
      expect(subject.content).to eq('Response text')
    end
  end

  describe '#data' do
    it 'returns the raw response hash' do
      expect(subject.data).to eq(JSON.parse(response_body))
    end
  end

  describe '#token_count' do
    it 'returns correct counts' do
      expect(subject.input_token_count).to eq(10)
      expect(subject.output_token_count).to eq(20)
    end
  end

  context 'with tool use' do
    let(:response_body) do
      {
        candidates: [
          {
            content: {
              parts: [
                {
                  functionCall: {
                    name: 'get_weather',
                    args: { location: 'London' }
                  }
                }
              ]
            }
          }
        ]
      }.to_json
    end

    it 'detects tool use' do
      expect(subject.tool_use?).to be true
    end

    it 'extracts tool inputs' do
      inputs = subject.tool_inputs
      expect(inputs.size).to eq(1)
      expect(inputs.first['name']).to eq('get_weather')
      expect(inputs.first['input']).to eq({ 'location' => 'London' })
    end
  end
end
