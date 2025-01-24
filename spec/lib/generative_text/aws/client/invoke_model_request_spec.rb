require 'rails_helper'

RSpec.describe GenerativeText::AWS::Client::InvokeModelRequest do
  subject(:request) { described_class.new(prompt:, **params) }

  let(:prompt) { 'Generate something interesting.' }
  let(:params) do
    {
      max_tokens: 100,
      stop_sequences: ['</s>', '<s>'],
      temp: 0.5,
      top_p: 0.9
    }
  end
  let(:model_id) { 'amazon.titan-text-express-v1' }

  describe '#to_h' do
    it 'returns the request as a hash' do
      expected_hash = {
        model_id:,
        content_type: 'application/json',
        accept: 'application/json',
        body: {
          'inputText' => prompt,
          'textGenerationConfig' => {
            'maxTokenCount' => params.fetch(:max_tokens),
            'stopSequences' => params.fetch(:stop_sequences),
            'temperature' => params.fetch(:temp),
            'topP' => params.fetch(:top_p)
          }
        }.to_json
      }

      expect(request.to_h).to eq(expected_hash)
    end

    context 'with default values' do
      let(:params) { {} }
      let(:default_model) { GenerativeText::AWS::MODELS.find { _1.api_name == 'amazon.titan-text-express-v1' } }

      it 'sets default values for each of the text gen config params' do
        expected_hash = {
          model_id: default_model.api_name,
          content_type: 'application/json',
          accept: 'application/json',
          body: {
            'inputText' => prompt,
            'textGenerationConfig' => {
              'maxTokenCount' => default_model.max_tokens,
              'stopSequences' => [],
              'temperature' => described_class::TEMP,
              'topP' => described_class::TOP_P
            }
          }.to_json
        }

        expect(request.to_h).to eq(expected_hash)
      end
    end
  end
end
