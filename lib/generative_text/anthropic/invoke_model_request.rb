class GenerativeText
  module Anthropic
    class InvokeModelRequest
      attr_reader :generate_text_request, :stream

      delegate :model, :prompt, :temperature, :file, :conversation, :system_message, to: :generate_text_request

      def initialize(generate_text_request, stream: false)
        @generate_text_request = generate_text_request
        @stream = stream
      end

      def to_h
        {
          model: model.api_name,
          max_tokens: model.max_tokens,
          stream:,
          system: system_message,
          tools:,
          tool_choice: { type: :auto },
          temperature:,
          messages:
        }.compact
      end

      def as_json = to_h

      private

      def messages
        turns = generate_text_request.conversation.turns.to_a
        conversation.exchange.push(Turn.user_turn(generate_text_request, turns:))
      end

      def tools
        LlmTool.active
      end
    end
  end
end
