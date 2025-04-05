require 'rails_helper'

RSpec.describe Embeddings::Voyage::EmbeddingRequest do
  describe '#as_json' do
    subject(:embedding_request) do
      described_class.new(input:, input_type:)
    end

    let(:input) { 'This is a test input' }
    let(:input_type) { :document }

    it 'returns a hash with the correct keys and values' do
      expected_hash = {
        input:,
        model: described_class::DEFAULT_MODEL,
        input_type: input_type.to_s,
        truncation: true,
        output_dimension: described_class::DEFAULT_DIMENSION
      }

      expect(embedding_request.as_json).to eq(expected_hash)
    end

    context 'with all options provided' do
      subject(:embedding_request) do
        described_class.new(input:, input_type:, model:, truncation:,
                            output_dimension:)
      end

      let(:input) { 'This is a test input' }
      let(:input_type) { :query }
      let(:model) { described_class::DEFAULT_MODEL }
      let(:truncation) { true }
      let(:output_dimension) { described_class::DEFAULT_DIMENSION }

      it 'returns a hash with the correct keys and values' do
        expected_hash = {
          input:,
          model:,
          input_type: input_type.to_s,
          truncation:,
          output_dimension:
        }

        expect(embedding_request.as_json).to eq(expected_hash)
      end
    end
  end
end
