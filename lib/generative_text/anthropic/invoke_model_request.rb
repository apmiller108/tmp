class GenerativeText
  module Anthropic
    class InvokeModelRequest
      attr_reader :generate_text_request

      delegate :model, :prompt, :temperature, :file, :conversation, :system_message, to: :generate_text_request

      def initialize(generate_text_request, **opts)
        @generate_text_request = generate_text_request
        @opts = opts
      end

      def to_h
        {
          model: model.api_name,
          max_tokens: model.max_tokens,
          temperature:,
          messages:,
          system: system_message
        }.compact
      end

      def as_json
        to_h
      end

      private

      def messages
        conversation.exchange.push(Turn.user_turn(generate_text_request))
      end
    end
  end
end
