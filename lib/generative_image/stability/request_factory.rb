class GenerativeImage
  module Stability
    class RequestFactory
      def self.create(endpoint, **args)
        case endpoint
        when :core
          CoreImageRequest.new(**args)
        when :ultra
          UltraImageRequest.new(**args)
        else
          raise ArgumentError, "Unknown endpoint: #{endpoint}"
        end
      end
    end
  end
end
