class GenerativeImage
  module Stability
    class TextToImageResponse
      attr_reader :response

      delegate :headers, :body, to: :response

      # param [Object] response that responds to `body` and `headers` (eg, Farady::Response)
      def initialize(response)
        @response = response
      end

      def image
        body
      end

      def image_present?
        image.length.positive?
      end

      def seed
        headers['seed']
      end

      # SUCCESS or CONTENT_FILTERED
      def finish_reason
        headers['finish-reason']
      end
    end
  end
end
