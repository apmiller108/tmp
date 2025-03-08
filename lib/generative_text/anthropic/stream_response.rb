class GenerativeText
  module Anthropic
    class StreamResponse
      attr_reader :message, :content_blocks, :complete

      def initialize
        @message = {}
        @content_blocks = []
        @complete = false
      end

      # rubocop:disable Metrics/MethodLength
      def update(event_type:, event_data:)
        case event_type
        when 'message_start'
          @message = event_data.fetch('message')
        when 'content_block_start'
          index = event_data.fetch('index')
          @content_blocks[index] = event_data.fetch('content_block')
        when 'content_block_delta'
          parse_content_delta(event_data)
        when 'message_delta'
          parse_message_delta(event_data)
        when 'message_stop'
          @complete = true
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Convert to format expected by InvokeModelResponse
      def to_response_format
        message.merge({ 'content' => content_blocks })
      end

      private

      def parse_content_delta(data)
        index = data.fetch('index')
        if data.dig('delta', 'type') == 'text_delta'
          @content_blocks[index]['text'] += data.dig('delta', 'text')
        end
      end

      def parse_message_delta(data)
        @message.merge!(data.fetch('delta'))
        @message['usage'] = @message['usage'].merge(data.fetch('usage', {}))
      end
    end
  end
end
