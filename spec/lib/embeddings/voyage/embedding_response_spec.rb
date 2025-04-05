require 'rails_helper'

RSpec.describe Embeddings::Voyage::EmbeddingResponse do
  subject(:embedding_response) { described_class.new(response_data) }

  let(:vector) { Array.new(1024) { rand } }
  let(:response_data) do
    {
      'data' => [
        {
          'object' => 'embedding',
          'embedding' => vector,
          'index' => 0
        }
      ],
      'model' => 'voyage-3',
      'usage' => { 'total_tokens' => 10 }
    }
  end

  describe '#embeddings' do
    it 'returns an array of Embedding objects' do
      embeddings = embedding_response.embeddings
      expect(embeddings).to all(be_a(described_class::Embedding))
    end

    it 'correctly maps the vector and index from response data' do
      embedding = embedding_response.embeddings.first
      expect(embedding.to_h).to eq({ vector:, index: 0 })
    end

    context 'with multiple embeddings' do
      let(:vector2) { Array.new(1024) { rand } }
      let(:response_data) do
        {
          'data' => [
            {
              'object' => 'embedding',
              'embedding' => vector,
              'index' => 0
            },
            {
              'object' => 'embedding',
              'embedding' => vector2,
              'index' => 1
            }
          ],
          'model' => 'voyage-3',
          'usage' => { 'total_tokens' => 20 }
        }
      end

      it 'returns all embeddings' do
        embeddings = embedding_response.embeddings
        expect(embeddings).to eq([described_class::Embedding.new(vector:, index: 0),
                                  described_class::Embedding.new(vector: vector2, index: 1)])
      end
    end

    it 'memoizes the result' do
      expect(response_data).to receive(:fetch).with('data').once.and_call_original
      2.times { embedding_response.embeddings }
    end
  end

  describe '#model' do
    it 'returns the model from response data' do
      expect(embedding_response.model).to eq('voyage-3')
    end
  end

  describe '#usage' do
    it 'returns the usage from response data' do
      expect(embedding_response.usage).to eq({ 'total_tokens' => 10 })
    end
  end
end
