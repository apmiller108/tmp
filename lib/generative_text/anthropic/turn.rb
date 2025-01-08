class GenerativeText
  module Anthropic
    module Turn
      module_function

      ASSISTANT = 'assistant'.freeze
      USER = 'user'.freeze

      # Converts a GenerateTextRequest object to a tuple that consists of a user
      # message and an assistant response.
      # @param [GenerateTextRequest]
      # @return [Array<Hash>]
      def for(generate_text_request)
        [
          {
            'role' => USER,
            'content' => [
              { 'text' => generate_text_request.prompt, 'type' => 'text' }
            ]
          },
          { 'role' => ASSISTANT, 'content' => generate_text_request.response_content || 'no content' }
        ]
      end
    end
  end
end
