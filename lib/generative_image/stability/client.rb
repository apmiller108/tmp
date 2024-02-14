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

      # @return [String] png file binary
      def text_to_image(prompts:, **opts)
        request = TextToImageRequest.new(prompts:, **opts)

        response = conn.post(request.path) do |req|
          req.body = request.to_json
          req.headers['Accept'] = 'image/png'
        end
        response.body
      rescue Faraday::ClientError => e
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
