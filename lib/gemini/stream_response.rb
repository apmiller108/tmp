module Gemini
  class StreamResponse
    attr_reader :content_blocks, :usage_metadata

    def initialize
      @content_blocks = []
      @usage_metadata = {}
      @accumulated_text = ""
    end

    def update(event)
      text = event.text_content
      if text
        @accumulated_text += text
      end
      
      if event.function_call
        @function_call = event.function_call
      end
      
      if event.usage_metadata
        @usage_metadata = event.usage_metadata
      end
    end

    # Convert to format expected by InvokeModelResponse (and wrapper logic)
    def to_response_format
      parts = []
      parts << { 'text' => @accumulated_text } if @accumulated_text.present?
      parts << { 'functionCall' => @function_call } if @function_call.present?

      {
        'candidates' => [
          {
            'content' => {
              'parts' => parts
            }
          }
        ],
        'usageMetadata' => @usage_metadata
      }
    end
  end
end
