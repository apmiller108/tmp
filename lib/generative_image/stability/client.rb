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
      # @param endpoint [Symbol] :core or :ultra
      # @return [Stability::ImageResponse] wraps the response
      def text_to_image(prompts:, endpoint: :core, **opts)
        request = create_request(endpoint, prompts:, **opts)

        response = conn.post(request.path) do |req|
          req.body = request.as_json
          req.headers['Accept'] = 'image/*'
        end
        ImageResponse.new(response)
      rescue Faraday::Error => e
        message = "#{e}: #{e.response_status}: #{e.response_body}"
        Rails.logger.warn "#{self.class} : #{message}"
        raise Stability::ClientError, message
      end

      # @param prompts [Array<Hash>] list of prompts with `text` and `weight`
      # @param image_data [String] binary image data
      # @param strength [Float] between 0 and 1, controls influence of input image
      # @return [Stability::ImageResponse] wraps the response
      def image_to_image(prompts:, image_data:, strength: 0.7, **opts)
        # Only Ultra endpoint supports image-to-image
        request = UltraImageRequest.new(
          prompts:,
          image_data:,
          strength:,
          **opts
        )

        response = conn.post(request.path) do |req|
          req.body = request.as_json
          req.headers['Accept'] = 'image/*'
        end
        ImageResponse.new(response)
      rescue Faraday::Error => e
        message = "#{e}: #{e.response_status}: #{e.response_body}"
        Rails.logger.warn "#{self.class} : #{message}"
        raise Stability::ClientError, message
      end

      private

      def create_request(endpoint, **args)
        case endpoint
        when :core
          CoreImageRequest.new(**args)
        when :ultra
          UltraImageRequest.new(**args)
        else
          raise ArgumentError, "Unknown endpoint: #{endpoint}"
        end
      end

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
