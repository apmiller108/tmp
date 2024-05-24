class GenerativeImage
  module Stability
    module TextToImageRequest
      def self.call(**args)
        if args[:v2]
          TextToImageRequestV2.new(**args)
        else
          TextToImageRequestV1.new(**args)
        end
      end
    end
  end
end
