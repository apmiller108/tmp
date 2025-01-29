require 'rails_helper'

RSpec.describe GenerativeText::AWS::InvokeModelRequest do
  subject(:request) { described_class.new(generate_text_request) }

  let(:generate_text_request) do
    build_stubbed :generate_text_request, :with_aws_model, prompt:, temperature:, markdown_format: false
  end
  let(:model) { generate_text_request.model }
  let(:temperature) { 0.5 }
  let(:prompt) { 'Generate something interesting.' }

  describe '#to_h' do
    it 'returns the request as a hash' do
      expected_hash = {
        model_id: model.api_name,
        content_type: 'application/json',
        accept: 'application/json',
        body: {
          'inputText' => format(GenerativeText::AWS::Turn::TEMPLATE, prompt:, response: '').strip,
          'textGenerationConfig' => {
            'maxTokenCount' => model.max_tokens,
            'stopSequences' => [],
            'temperature' => temperature,
            'topP' => described_class::TOP_P
          }
        }.to_json
      }

      expect(request.to_h).to eq(expected_hash)
    end
  end
end
