module Gemini
  class InvokeModelResponse
    attr_reader :data

    def initialize(response_body)
      @response_json = if response_body.is_a?(Hash)
                         response_body
                       else
                         JSON.parse(response_body)
                       end
      @data = @response_json
    end

    def content
      # Return the text content
      results.find { |c| c['type'] == 'text' }&.fetch('text')
    end
    
    def tool_use?
      tool_inputs.any?
    end

    def tool_inputs
      results.select { |c| c['type'] == 'tool_use' }
    end

    def blobify
      [
        content,
        *tool_inputs.map { _1['input'] }
      ].join(' ')
    end

    # Support for metadata if needed
    def input_token_count
      usage_metadata['promptTokenCount'].to_i
    end

    def output_token_count
      usage_metadata['candidatesTokenCount'].to_i
    end

    private

    def results
      @results ||= begin
        parts = candidates.first&.dig('content', 'parts') || []
        parts.map do |part|
          if part['text'].present?
            { 'type' => 'text', 'text' => part['text'] }
          elsif part['functionCall'].present?
            {
              'type' => 'tool_use',
              'name' => part['functionCall']['name'],
              'input' => part['functionCall']['args']
            }
          end
        end.compact
      end
    end

    def candidates
      @response_json['candidates'] || []
    end

    def usage_metadata
      @response_json['usageMetadata'] || {}
    end
  end
end
