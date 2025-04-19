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

      # @param generate_image_request [GenerateImageRequest]
      # @return [Stability::ImageResponse] wraps the response
      def perform_request(generate_image_request)
        endpoint = endpoint_for(generate_image_request)
        request = RequestFactory.create(endpoint, generate_image_request)

        post_image_request(request)
      rescue Faraday::Error => e
        message = "#{e}: #{e.response_status}: #{e.response_body}"
        Rails.logger.warn "#{self.class} : #{message}"
        raise ContentError, message if e.response_status == 403

        raise ClientError, message
      ensure
        request&.close
      end

      private

      # Only Ultra endpoint supports image-to-image. Core does not.
      def endpoint_for(generate_image_request)
        if generate_image_request.image_to_image? || generate_image_request.high_quality_text_to_image?
          ULTRA_GENERATION_ENDPOINT
        elsif generate_image_request.standard_quality_text_to_image?
          CORE_GENERATION_ENDPOINT
        elsif generate_image_request.upscale?
          UPSCALE_FAST_ENDPOINT
        end
      end

      def post_image_request(request)
        response = conn.post(request.path) do |req|
          req.body = request.as_json
          req.headers['Accept'] = 'image/*'
        end

        ImageResponse.new(response)
      end

      def conn
        Faraday.new(
          url: HOST,
          headers: {
            'Authorization': "Bearer #{ENV.fetch('STABILITY_KEY')}",
            'Content-Type': 'multipart/form-data'
          }
        ) do |f|
          f.request :multipart
          f.response :raise_error
          # f.response :logger, nil, { bodies: { request: true, response: true } } # Log request and response to stdout
        end
      end
    end
  end
end
