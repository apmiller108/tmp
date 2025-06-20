module Anthropic
  class Turn
    ASSISTANT = 'assistant'.freeze
    USER = 'user'.freeze

    # Converts a GenerateTextRequest object to a tuple that consists of a user
    # message and an assistant response.
    # @param [GenerateTextRequest] generate_text_request
    # @param [Array<ConversationTurn>]
    # @return [Array<Hash>]
    def self.for(generate_text_request, turns: [])
      new(generate_text_request:, turns:).turn
    end

    def self.user_turn(generate_text_request, turns: [])
      new(generate_text_request:, turns:).user_turn
    end

    attr_reader :generate_text_request, :turns

    delegate :prompt, :response_content, to: :generate_text_request
    alias assistant_content response_content

    def initialize(generate_text_request:, turns:)
      @generate_text_request = generate_text_request
      @turns = turns
    end

    def turn
      [
        user_turn,
        assistant_turn
      ]
    end

    # Builds a user turn Hash. It contains a `content` Array which can have
    # several hashes: text, images, pdfs, etc... When the previous turn is an
    # image request, include it in the next user turn so the LLM will have the
    # image in it's context window.
    def user_turn
      {
        'role' => USER,
        'content' => user_content
      }
    end

    def assistant_turn
      {
        'role' => ASSISTANT,
        'content' => assistant_content || 'no content'
      }
    end

    private

    def user_content
      [
        user_generate_image_content,
        user_upload_image_content,
        user_text_content
      ].compact
    end

    def user_text_content
      { 'text' => prompt, 'type' => 'text' }
    end

    def user_upload_image_content
      return unless generate_text_request.image_attached?

      user_image_content(image: generate_text_request.file.variant(:webp).processed.image)
    end

    def user_generate_image_content
      return unless previous_turn.present? && previous_turn.generated_image?

      user_image_content(image: previous_turn.turnable.image.variant(:webp).image)
    end

    def user_image_content(image:)
      return unless generate_text_request.image_capable?

      {
        'type' => 'image',
        'source' => {
          'type' => 'base64',
          'media_type' => image.content_type,
          'data' => BlobEncoder.encode64(image)
        },
        'cache_control' => { 'type' => 'ephemeral' }
      }
    end

    def previous_turn
      turn_index.positive? ? turns[turn_index - 1] : nil
    end

    # In the special case of creating summaries, there won't be a Conversation
    # (NullConversation) and hence turns will be empty. In this case return 0
    # for the turn_index.
    def turn_index
      turns.find_index { _1.turnable_id == generate_text_request.id } || 0
    end
  end
end
