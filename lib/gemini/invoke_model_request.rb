module Gemini
  class InvokeModelRequest
    attr_reader :generate_text_request, :stream

    delegate :model, :prompt, :temperature, :system_message, :conversation, to: :generate_text_request

    def initialize(generate_text_request, stream: false)
      @generate_text_request = generate_text_request
      @stream = stream
    end

    def to_h
      {
        contents:,
        tools:,
        generationConfig: generation_config,
        systemInstruction: system_instruction
      }.compact
    end

    def to_json
      to_h.to_json
    end

    private

    def tools
      active_tools = LlmTool.active.where(tool_type: conversation.tool_types)
      return nil if active_tools.empty?

      function_declarations = active_tools.map do |tool|
        {
          name: tool.name,
          description: tool.description,
          parameters: tool.input_schema
        }
      end

      [{ function_declarations: }]
    end

    def contents
      turns = conversation.turns.to_a
      # Get history + current turn
      ex = conversation.exchange.push(Turn.user_turn(generate_text_request, turns:))

      # Prepend context documents to the first message if any
      if conversation.respond_to?(:contexts) && conversation.contexts.any?
        file_parts = Array(conversation.contexts).select { |c| c.vendor == 'google' }.map do |context|
          next unless context.file_ref.start_with?('https://')

          {
            file_data: {
              mime_type: context.mime_type,
              file_uri: context.file_ref
            }
          }
        end.compact

        if file_parts.any? && ex.last && ex.last[:role] == 'user'
          ex.last[:parts].unshift(*file_parts)
        end
      end

      ex
    end

    def generation_config
      {
        temperature: temperature,
        # topP: ...,
        # topK: ...,
        # maxOutputTokens: ...
      }.compact
    end

    def system_instruction
      return nil if system_message.blank?

      {
        parts: [
          { text: system_message }
        ]
      }
    end
  end
end
