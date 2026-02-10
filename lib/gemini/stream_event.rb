module Gemini
  class StreamEvent
    attr_reader :data

    # Parse a raw SSE string into a StreamEvent object
    def self.parse(raw_event)
      # Gemini typically sends "data: { ... }"
      # It might not send "event: ..." lines.
      
      lines = raw_event.split("\n")
      data_line = lines.find { |l| l.start_with?('data: ')}
      
      return nil unless data_line
      
      json_str = data_line.sub(/^data: /, '')
      parsed_data = JSON.parse(json_str)
      
      new(data: parsed_data)
    rescue JSON::ParserError
      # Verify if it's a [DONE] message or similar? 
      # Gemini REST API might just end.
      nil
    end

    def initialize(data:)
      @data = data
    end

    def text?
      text_content.present?
    end

    def text_content
      @data.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end

    def function_call
      @data.dig('candidates', 0, 'content', 'parts', 0, 'functionCall')
    end

    def usage_metadata
      @data['usageMetadata']
    end
  end
end
