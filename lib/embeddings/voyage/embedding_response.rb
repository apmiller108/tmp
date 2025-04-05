module Embeddings
  module Voyage
    class EmbeddingResponse
      attr_reader :response_data

      Embedding = Data.define(:vector, :index)

      # @param response_data [Hash]
      # { data: [{ object: 'embedding', embedding: Array.new(1024) { rand }, index: 0 }],
      #   model: 'voyage-3',
      #   useage: { total_tokens: 10 } }
      def initialize(response_data)
        @response_data = response_data
      end

      def embeddings
        @embeddings ||= response_data.fetch('data').map do |item|
          Embedding.new(
            vector: item.fetch('embedding'),
            index: item.fetch('index')
          )
        end
      end

      def model
        response_data.fetch('model')
      end

      def usage
        response_data.fetch('usage')
      end
    end
  end
end
