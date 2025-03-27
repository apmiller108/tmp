module Embeddings
  module Voyage
    HOST = 'https://api.voyageai.com/'.freeze

    # @param text [String | Array<String>] text for which to create the embedding
    # @param input_type [Symbol] enum :document or :query
    # @return [Embeddings::Voyage::Response]
    def self.create_embedding(text:, input_type:)
      request = EmbeddingRequest.new(
        input: Array[text],
        input_type:
      )

      Client.new.create_embedding(request)
    end
  end
end
