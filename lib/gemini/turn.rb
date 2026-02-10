module Gemini
  class Turn
    ASSISTANT = 'model'.freeze
    USER = 'user'.freeze

    # Converts a GenerateTextRequest object to a tuple that consists of a user
    # message and an assistant response.
    def self.for(generate_text_request, turns: [], include_previous_gen_image: false)
      new(generate_text_request:, turns:, include_previous_gen_image:).turn
    end

    def self.user_turn(generate_text_request, turns: [], include_previous_gen_image: true)
      new(generate_text_request:, turns:, include_previous_gen_image:).user_turn
    end

    attr_reader :generate_text_request, :turns, :include_previous_gen_image

    delegate :prompt, :response_content, to: :generate_text_request
    alias assistant_content response_content

    def initialize(generate_text_request:, turns:, include_previous_gen_image: false)
      @include_previous_gen_image = include_previous_gen_image
      @generate_text_request = generate_text_request
      @turns = turns
    end

    def turn
      [
        user_turn,
        assistant_turn
      ]
    end

    def user_turn
      {
        role: USER,
        parts: user_parts
      }
    end

    def assistant_turn
      {
        role: ASSISTANT,
        parts: [{ text: assistant_content || 'no content' }]
      }
    end

    private

    def user_parts
      [
        user_generate_image_part,
        user_upload_image_part,
        user_text_part
      ].compact
    end

    def user_text_part
      { text: prompt }
    end

    # Phase 4 implementation placeholder
    def user_upload_image_part
      return unless generate_text_request.image_attached?

      # Use inline data for now, similar to Anthropic,
      # but Gemini supports inline_data or file_data (Files API)
      # For parity with current Anthropic implementation (base64 source), we use inline_data.

      image = generate_text_request.file.variant(:webp).processed.image

      {
        inline_data: {
          mime_type: image.content_type,
          data: BlobEncoder.encode64(image)
        }
      }
    end

    def user_generate_image_part
      return unless include_previous_gen_image && previous_turn.present? && previous_turn.generated_image?

      image = previous_turn.turnable.image.variant(:webp).image

      {
        inline_data: {
          mime_type: image.content_type,
          data: BlobEncoder.encode64(image)
        }
      }
    end

    def previous_turn
      turn_index.positive? ? turns[turn_index - 1] : nil
    end

    def turn_index
      turns.find_index { _1.turnable_id == generate_text_request.id } || 0
    end
  end
end
