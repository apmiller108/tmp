class GenerativeImage
  module Stability
    class RequestFactory
      def self.create(service, generate_image_request)
        case service
        when :core
          CoreRequest.new(generate_image_request)
        when :ultra
          UltraRequest.new(generate_image_request)
        else
          raise ArgumentError, "Unknown service: #{service}"
        end
      end
    end
  end
end
