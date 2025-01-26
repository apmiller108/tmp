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
          user_turn(generate_text_request),
          { 'role' => ASSISTANT, 'content' => generate_text_request.response_content || 'no content' }
        ]
      end

      def user_turn(generate_text_request)
        {
          'role' => USER,
          'content' => [
            { 'text' => generate_text_request.prompt, 'type' => 'text' }
          ].tap do |content|
            if generate_text_request.file.attached?
              content.prepend(
                {
                  'type' => 'image',
                  'source' => {
                    'type' => 'base64',
                    'media_type' => generate_text_request.file.content_type,
                    'data' => BlobEncoder.encode64(generate_text_request.file)
                  },
                  'cache_control' => { 'type' => 'ephemeral' }
                }
              )
            end
          end
        }
      end
    end
  end
end
