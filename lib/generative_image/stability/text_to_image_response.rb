class GenerativeImage
  module Stability
    class TextToImageResponse
      attr_reader :parsed_json

      # Example parsed json
      # {"artifacts"=>[{"base64"=>"foo", "seed"=>3939457358, "finishReason"=>"SUCCESS"}]}
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

      def artifact
        parsed_json['artifacts']
      end
    end
  end
end
