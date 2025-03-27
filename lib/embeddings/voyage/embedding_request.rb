# app/services/embeddings/voyage/request.rb
module Embeddings
  module Voyage
    class EmbeddingRequest
      DEFAULT_MODEL = 'voyage-3'.freeze
      DEFAULT_DIMENSION = 1024

      attr_reader :input, :model, :input_type, :truncation, :output_dimension

      def initialize(input:, input_type:, model: DEFAULT_MODEL, truncation: true, output_dimension: DEFAULT_DIMENSION)
        @input = input
        @input_type = input_type.to_s
        @model = model
        @truncation = truncation
        @output_dimension = output_dimension
      end

      def as_json
        {
          input:,
          model:,
          input_type:,
          truncation:,
          output_dimension:
        }
      end
    end
  end
end
