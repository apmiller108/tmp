module Embeddings
  module Voyage
    HOST = 'https://api.voyageai.com/'.freeze

    # @param text [String | Array<String>] text for which to create the embedding
    # @param input_type [Symbol] enum :document or :query
    # @return [Embeddings::Voyage::Response]
    class << self
      def create_embeddings(text:, input_type:)
        raise ArgumentError, 'input_type must be one of :query or :document' unless input_type.in?(%i[document query])

        case input_type
        when :query
          cache_key = "query_embedding/#{Digest::MD5.hexdigest(text.to_s.downcase.strip)}"
          Rails.cache.fetch(cache_key, expires_in: 24.hours) do
            _create_embeddings(text:, input_type:)
          end
        else
          _create_embeddings(text:, input_type:)
        end
      end

      private

      def _create_embeddings(text:, input_type:)
        request = EmbeddingRequest.new(
          input: Array[text],
          input_type:
        )

        Client.new.create_embeddings(request)
      end
    end
  end
end
