module Anthropic
  class StreamResponse
    attr_reader :message, :content_blocks, :complete

    def initialize
      @message = {}
      @content_blocks = []
      @complete = false
    end

    # rubocop:disable Metrics/MethodLength
    # Update the response state based on an event
    # @param event [StreamEvent] The event to process
    def update(event)
      case event.type
      when 'message_start'
        @message = event.message
      when 'content_block_start'
        parse_content_start(event)
      when 'content_block_delta'
        parse_content_delta(event)
      when 'content_block_stop'
        parse_content_block_stop(event)
      when 'message_delta'
        parse_message_delta(event)
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

    def parse_content_start(event)
      content_block = event.content_block
      case event.content_block_type
      when 'text'
        @content_blocks[event.index] = content_block
      when 'tool_use'
        # Input is an empty hash to at the start. Its easier to make it a
        # string and append partial JSON strings to it, then parse the JSON at
        # the end.
        content_block['input'] = ''
        @content_blocks[event.index] = content_block
      end
    end

    def parse_content_delta(event)
      case event.delta_type
      when 'text_delta'
        @content_blocks[event.index]['text'] += event.delta_text
      when 'input_json_delta'
        @content_blocks[event.index]['input'] += event.delta_partial_json
      end
    end

    def parse_content_block_stop(event)
      content_block = @content_blocks[event.index]
      case content_block['type']
      when 'tool_use'
        begin
          content_block['input'] = JSON.parse(content_block['input'])
        rescue JSON::ParserError
          Rails.logger.warn("#{self.class} : invalid JSON tool use input")
          content_block['input'] = {}
        end
      end
    end

    def parse_message_delta(event)
      @message.merge!(event.data.fetch('delta'))
      @message['usage'] = @message['usage'].merge(event.usage)
    end
  end
end
