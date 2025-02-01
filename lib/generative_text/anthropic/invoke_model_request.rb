class GenerativeText
  module Anthropic
    class InvokeModelRequest
      attr_reader :generate_text_request

      delegate :model, :prompt, :temperature, :file, :conversation, :system_message, to: :generate_text_request

      def initialize(generate_text_request)
        @generate_text_request = generate_text_request
      end

      def to_h
        {
          model: model.api_name,
          max_tokens: model.max_tokens,
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
        conversation.exchange.push(Turn.user_turn(generate_text_request))
      end

      def tools
        ToolBox.all_tools
      end
    end
  end
end
