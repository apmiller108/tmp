class GenerativeText
  module Anthropic
    class InvokeModelResponse
      attr_reader :data

      # @param [Hash | String] data
      # Parsed JSON response will look like this
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
      #         "input_tokens" => 79, "output_tokens" => 942,
      #         "cache_creation_input_tokens"=>0, "cache_read_input_tokens"=>1601
      #     }
      # }
      def initialize(data)
        @data = if data.respond_to? :keys
                  data
                else
                  JSON.parse(data)
                end
      end

      def content
        results.find { |c| c['type'] == 'text' }.fetch('text')
      end

      def results
        data.fetch('content')
      end

      def completion_reason
        # stop_reason could be one of ["end_turn", "max_tokens", "stop_sequence"]
        data.fetch('stop_reason')
      end

      def token_count
        usage.fetch('input_tokens') + usage.fetch('output_tokens') +
          usage.fetch('cache_creation_input_tokens') + usage.fetch('cache_read_input_tokens')
      end

      def usage
        data.fetch('usage')
      end
    end
  end
end
