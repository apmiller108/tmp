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
      # @return [Stability::TextToImageResponse] wraps the response
      def text_to_image(prompts:, **opts)
        request = TextToImageRequest.new(prompts:, **opts)

        response = conn.post(request.path) do |req|
          req.body = request.as_json
          req.headers['Accept'] = 'image/*'
        end
        TextToImageResponse.new(response)
      rescue Faraday::Error => e
        raise Stability::ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      def conn
        Faraday.new(
          url: HOST,
          headers: {
            'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
            'Content-Type': 'multipart/form-data'
          }
        ) do |f|
          f.request :multipart
          f.response :raise_error
        end
      end
    end
  end
end
