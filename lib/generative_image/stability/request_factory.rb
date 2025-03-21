class GenerativeImage
  module Stability
    class RequestFactory
      def self.create(endpoint, generate_image_request)
        case endpoint
        when CORE_GENERATION_ENDPOINT
          CoreRequest.new(generate_image_request)
        when ULTRA_GENERATION_ENDPOINT
          UltraRequest.new(generate_image_request)
        when UPSCALE_FAST_ENDPOINT
          UpscaleFastRequest.new(generate_image_request)
        else
          raise ArgumentError, "Unknown endpoint: #{endpoint}"
        end
      end
    end
  end
end
