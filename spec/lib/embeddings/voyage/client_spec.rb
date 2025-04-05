require 'rails_helper'

RSpec.describe Embeddings::Voyage::Client do
  subject(:client) { described_class.new }

  let(:host) { 'https://api.voyageai.com' }

  describe '#create_embeddings' do
    let(:request) { instance_double(Embeddings::Voyage::EmbeddingRequest, to_json: request_body) }
    let(:request_body) do
      '{"input":["test"],"model":"voyage-3","input_type":"query","truncation":true,"output_dimension":1024}'
    end
    let(:embedding) { Array.new(1024) { rand } }
    let(:response_data) do
      {
        'data' => [
          {
            'object' => 'embedding',
            'embedding' => embedding,
            'index' => 0
          }
        ],
        'model' => 'voyage-3',
        'usage' => { 'total_tokens' => 10 }
      }
    end
    let(:embedding_response) { instance_double(Embeddings::Voyage::EmbeddingResponse) }

    before do
      stub_voyage_embedding_request(input: ['test'], input_type: :query, embedding:)
    end

    it 'returns a wrapper object for the response data' do
      response = client.create_embeddings(request)
      expect(response.response_data).to eq(response_data)
    end
  end
end
