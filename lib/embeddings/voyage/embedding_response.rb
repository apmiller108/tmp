# app/services/embeddings/voyage/response.rb
module Embeddings
  module Voyage
    class EmbeddingResponse
      attr_reader :response_data

      Embedding = Data.define(:vector, :index)

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
