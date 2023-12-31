require 'rails_helper'

RSpec.describe LLMService::AWS::Client::InvokeModelRequest do
  subject(:request) { described_class.new(prompt: prompt, **params) }

  let(:prompt) { 'Generate something interesting.' }
  let(:params) do
    {
      max_tokens: 100,
      stop_sequences: ['</s>', '<s>'],
      temp: 0.5,
      top_p: 0.9
    }
  end

  describe '#to_h' do
    it 'returns the request as a hash' do
      expected_hash = {
        model_id: LLMService::AWS::TITAN_EXPRESS,
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

      it 'sets default values for each of the text gen config params' do
        expected_hash = {
          model_id: LLMService::AWS::TITAN_EXPRESS,
          content_type: 'application/json',
          accept: 'application/json',
          body: {
            'inputText' => prompt,
            'textGenerationConfig' => {
              'maxTokenCount' => described_class::MAX_TOKENS,
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
