class GenerativeImage
  module Stability
    class TextToImageResponse
      attr_reader :data

      # Example parsed json
      # {"image": "AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1...", "finish_reason": "SUCCESS", "seed": 343940597 }
      def initialize(json)
        @data = JSON.parse(json)
      end

      def base64
        data['image']
      end

      def seed
        data['seed']
      end

      # SUCCESS or CONTENT_FILTERED
      def finish_reason
        data['finish_reason']
      end

      def image_present?
        base64.present?
      end
    end
  end
end
