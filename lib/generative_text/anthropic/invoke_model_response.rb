class GenerativeText
  module Anthropic
    class InvokeModelResponse
      attr_reader :response_data

      # JSON response will look like this
      # {
      #     "id" => "msg_01DMcCdRr6gaWDuZs7Y63rhe",
      #     "type" => "message",
      #     "role" => "assistant",
      #     "content" => [{
      #         "type" => "text",
      #         "text" => "response content goes here"
      #     }],
      #     "model" => "claude-3-haiku-20240307",
      #     "stop_reason" => "end_turn",
      #     "stop_sequence" => nil,
      #     "usage" => {
      #         "input_tokens" => 79, "output_tokens" => 942
      #     }
      # }
      def initialize(json)
        @response_data = JSON.parse(json)
      end

      def content
        results.select { |c| c['type'] == 'text' }
               .map    { |c| c['text'] }
               .join("\n")
      end

      def results
        response_data.fetch('content')
      end

      def completion_reason
        # stop_reason could be one of ["end_turn", "max_tokens", "stop_sequence"]
        results.fetch('stop_reason')
      end

      def token_count
        usage.fetch('input_tokens') + usage.fetch('output_tokens')
      end

      private

      def usage
        response_data.fetch('usage')
      end
    end
  end
end
