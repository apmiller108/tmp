module Embeddings
  module Voyage
    class Client
      EMBEDDINGS_PATH = '/v1/embeddings'.freeze
      ClientError = Class.new(StandardError)

      def create_embeddings(request)
        response = connection.post(EMBEDDINGS_PATH) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = request.to_json
        end

        EmbeddingResponse.new(JSON.parse(response.body))
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      def connection
        @connection ||= Faraday.new(url: HOST) do |f|
          f.headers['Authorization'] = "Bearer #{ENV.fetch('VOYAGE_API_KEY')}"
          f.adapter Faraday.default_adapter
          f.response :raise_error
        end
      end
    end
  end
end
