module Embeddings
  module Voyage
    class Client
      EMBEDDINGS_PATH = '/v1/embeddings'.freeze
      ClientError = Class.new(StandardError)

      def create_embedding(request)
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
          f.headers['Authorization'] = "Bearer #{api_key}"
          f.adapter Faraday.default_adapter
          f.response :raise_error
        end
      end

      def api_key
        @api_key ||= ENV.fetch('VOYAGE_API_KEY') do
          raise 'Missing VOYAGE_API_KEY environment'
        end
      end
    end
  end
end
