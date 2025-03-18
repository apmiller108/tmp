class GenerativeImage
  module Stability
    class CoreRequest < Request
      def path
        CORE_GENERATION_ENDPOINT
      end
    end
  end
end
