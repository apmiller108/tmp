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
        **tool_params,
        temperature:,
        messages:
      }.compact
    end

    def as_json = to_h

    private

    def tool_params
      return {} if tools.empty?

      {
        tools:,
        tool_choice: { type: :auto }
      }
    end

    # In some cases text is generated outside the context of a Conversation
    # (eg, summaries) In this case the NullConversation provides the empty
    # exchange.
    def messages
      turns = conversation.turns.to_a
      conversation.exchange.push(Turn.user_turn(generate_text_request, turns:))
    end

    def tools
      @tools ||= LlmTool.active.where(tool_type: conversation.tool_types)
    end
  end
end
