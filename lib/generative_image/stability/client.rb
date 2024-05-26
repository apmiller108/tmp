class GenerativeImage
  module Stability
    class Client
      # See https://platform.stability.ai/docs/api-reference

      def engines
        response = conn.get(ENGINES_ENDPOINT) do |req|
          req.headers['Accept'] = 'application/json'
        end
        JSON.parse(response.body)
      end

      # @param prompts [Array<Hash>] list of prompts with `text` and `weight`
      # keys @return [Stability::TextToImageResponse | Stability::TextToImageResponseV2 ] wraps the JSON response
      def text_to_image(prompts:, **opts)
        request = TextToImageRequest.call(prompts:, **opts)

        response = conn.post(request.path) do |req|
          req.body = request.to_json
          req.headers['Accept'] = 'application/json'
        end
        TextToImageResponse.new(response.body)
      rescue Faraday::Error => e
        raise Stability::ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      def conn
        Faraday.new(
          url: HOST,
          headers: {
            'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
            'Content-Type': 'application/json'
          }
        ) do |f|
          f.response :raise_error
        end
      end
    end
  end
end
