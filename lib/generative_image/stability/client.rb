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

      def perform_request(generate_image_request)
        if generate_image_request.image_to_image?
          image_to_image(generate_image_request:)
        else
          text_to_image(generate_image_request:)
        end
      end

      # @param endpoint [Symbol] :core or :ultra
      # @return [Stability::ImageResponse] wraps the response
      def text_to_image(generate_image_request:, endpoint: :core)
        request = create_request(endpoint, **generate_image_request.parameterize)

        post_image_request(request)
      rescue Faraday::Error => e
        message = "#{e}: #{e.response_status}: #{e.response_body}"
        Rails.logger.warn "#{self.class} : #{message}"
        raise Stability::ClientError, message
      end

      # @return [Stability::ImageResponse] wraps the response
      def image_to_image(generate_image_request:)
        # Only Ultra endpoint supports image-to-image
        request = create_request(:ultra, **generate_image_request.parameterize)

        post_image_request(request)
      rescue Faraday::Error => e
        message = "#{e}: #{e.response_status}: #{e.response_body}"
        Rails.logger.warn "#{self.class} : #{message}"
        raise Stability::ClientError, message
      end

      private

      def post_image_request(request)
        response = conn.post(request.path) do |req|
          req.body = request.as_json
          req.headers['Accept'] = 'image/*'
        end

        ImageResponse.new(response)
      end

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
