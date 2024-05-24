class GenerativeImage
  module Stability
    class TextToImageResponse
      attr_reader :parsed_json

      # Example parsed json
      # v1: {"artifacts"=>[{"base64"=>"base64 string", "seed"=>3939457358, "finishReason"=>"SUCCESS"}]}
      # v2: {"image": "AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1...", "finish_reason": "SUCCESS", "seed": 343940597 }
      def initialize(json)
        @parsed_json = JSON.parse(json)
      end

      def base64
        data['base64'] || data['image']
      end

      def seed
        data['seed']
      end

      # SUCCESS or CONTENT_FILTERED
      def finish_reason
        data['finishReason'] || data['finish_reason']
      end

      # Supports V1 and V2 responses. See examples above
      def data
        parsed_json['artifacts']&.first || parsed_json
      end

      def image_present?
        base64.present?
      end
    end
  end
end
