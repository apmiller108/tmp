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

      def text_to_image(prompt:, **opts)
        request = TextToImageRequest.new(prompt:, **opts)

        response = conn.post(request.path) do |req|
          req.body = request.to_json
          req.headers['Accept'] = 'image/png'
        end
        response
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
