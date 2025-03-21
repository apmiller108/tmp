class GenerativeImage
  module Stability
    class CoreRequest < BaseRequest
      def path
        CORE_GENERATION_ENDPOINT
      end
    end
  end
end
