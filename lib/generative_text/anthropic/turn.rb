class GenerativeText
  module Anthropic
    module Turn
      module_function

      ASSISTANT = 'assistant'.freeze
      USER = 'user'.freeze

      # Converts a GenerateTextRequest object to a tuple that consists of a user
      # message and an assistant response.
      # @param [GenerateTextRequest] generate_text_request
      # @param [Array<ConversationTurn>]
      # @return [Array<Hash>]
      def for(generate_text_request, turns:)
        [
          user_turn(generate_text_request, turns:),
          { 'role' => ASSISTANT, 'content' => generate_text_request.response_content || 'no content' }
        ]
      end

      # Builds a user turn Hash. It contains a `content` Array which can have
      # several hashes: text, images, pdfs, etc... When the previous turn is an
      # image request, include it in the next user turn so the LLM will have the
      # image in it's context window.
      def user_turn(generate_text_request, turns:)
        turn_index = turns.find_index { _1.turnable_id == generate_text_request.id }
        previous_turn = turn_index.positive? ? turns[turn_index - 1] : nil
        {
          'role' => USER,
          'content' => [
            { 'text' => generate_text_request.prompt, 'type' => 'text' }
          ].tap do |content|
            if generate_text_request.image_attached?
              add_user_image_content(content:, image: generate_text_request.file.variant(:webp))
            end
            if previous_turn.present? && previous_turn.generated_image?
              add_user_image_content(content:, image: previous_turn.turnable.image.variant(:webp))
            end
          end
        }
      end

      def add_user_image_content(content:, image:)
        content.prepend(
          {
            'type' => 'image',
            'source' => {
              'type' => 'base64',
              'media_type' => image.content_type,
              'data' => BlobEncoder.encode64(image.blob)
            },
            'cache_control' => { 'type' => 'ephemeral' }
          }
        )
      end
    end
  end
end
