class GenerativeImage
  module Stability
    class TextToImageResponse
      attr_reader :parsed_json

      # Example parsed json
      # {"artifacts"=>[{"base64"=>"base64 string", "seed"=>3939457358, "finishReason"=>"SUCCESS"}]}
      def initialize(json)
        @parsed_json = JSON.parse(json)
      end

      def base64
        artifact['base64']
      end

      def seed
        artifact['seed']
      end

      def finish_reason
        artifact['finishReason']
      end

      # For now the app will support creating one image per request
      def artifact
        parsed_json['artifacts'].first
      end

      def image_present?
        base64.present?
      end
    end
  end
end
