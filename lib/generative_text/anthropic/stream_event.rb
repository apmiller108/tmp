class GenerativeText
  module Anthropic
    # Represents a single Server-Sent Event from Anthropic's streaming API
    class StreamEvent
      attr_reader :type, :data

      # Parse a raw SSE string into a StreamEvent object
      # @param raw_event [String] Raw SSE event string
      # @return [StreamEvent, nil] Parsed event or nil if invalid/ping
      def self.parse(raw_event)
        event_type, event_data = parse_raw_event(raw_event)

        return nil if event_type.nil? || event_data.nil? || event_type == 'ping'

        parsed_data = JSON.parse(event_data)
        new(type: event_type, data: parsed_data)
      rescue JSON::ParserError
        Rails.logger.warn "#{self.class} : invalid json"
        nil
      end

      # @param raw_event [String] Raw SSE event string
      # @return [String, String] Event type and event data.
      def self.parse_raw_event(raw_event)
        event_type = nil
        event_data = nil

        raw_event.split("\n").map do |line|
          if line.start_with?('event: ')
            event_type = line.sub(/^event: /, '')
          elsif line.start_with?('data: ')
            event_data = line.sub(/^data: /, '')
          end
        end

        [event_type, event_data]
      end

      def initialize(type:, data:)
        @type = type
        @data = data
      end

      def content_block_start?
        is?('content_block_start')
      end

      def content_block_delta?
        is?('content_block_delta')
      end

      # Get text content from content_block or delta events
      # @return [String, nil] Text content or nil if not a text event
      def text_content
        @text_content ||= if content_block_start? && content_block_type == 'text'
                            content_block_text
                          elsif content_block_delta? && delta_type == 'text_delta'
                            delta_text
                          end
      end

      def content_block_type
        data.dig('content_block', 'type')
      end

      # Check if this event contains text content
      # @return [Boolean] True if this event contains text content
      def text?
        text_content.present?
      end

      # Present for message_start event type
      def message
        data.fetch('message', nil)
      end

      # Present for content_block_start event type
      def content_block
        data.fetch('content_block')
      end

      def index
        data.fetch('index', nil)
      end

      def delta_type
        data.dig('delta', 'type')
      end

      def delta_text
        data.dig('delta', 'text')
      end

      def delta_partial_json
        data.dig('delta', 'partial_json')
      end

      def usage
        data.fetch('usage', {})
      end

      private

      def is?(event_type)
        @type == event_type
      end

      def content_block_text
        data.dig('content_block', 'text')
      end
    end
  end
end
