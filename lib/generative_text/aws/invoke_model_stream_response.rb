class GenerativeText
  module AWS
    class InvokeModelStreamResponse
      attr_reader :response_data

      # A series of event json will look like this:
      #
      # {"outputText": "0..-2 parts of stream", "index": 0,
      #  "totalOutputTextTokenCount": nil, "completionReason": nil,
      #  "inputTextTokenCount": 9}
      #
      # {"outputText": "final part of stream", "index": 0,
      #  "totalOutputTextTokenCount": 104, "completionReason": "FINISH",
      #  "inputTextTokenCount": nil, "amazon-bedrock-invocationMetrics":
      #  {"inputTokenCount": 9, "outputTokenCount": 104, "invocationLatency":
      #  3407, "firstByteLatency": 2440}}

      def initialize(json)
        @response_data = JSON.parse(json)
      end

      def content
        response_data.fetch('outputText')
      end

      def final_chunk?
        # completionReason could be one of ["LENGTH", "FINISH"]. The latter
        # meaning the response was truncated per the max_tokens.
        response_data.fetch('completionReason').present?
      end

      def token_count
        (metrics['inputTokenCount'] || 0) + (metrics['outputTokenCount'] || 0)
      end

      private

      def metrics
        response_data.fetch('amazon-bedrock-invocationMetrics', {})
      end
    end
  end
end
