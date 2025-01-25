class GenerativeText
  module AWS
    class Turn
      TEMPLATE =
        <<~TURN.freeze
          User: %<prompt>s
          Bot: %<response>s
        TURN

      def self.for(generate_text_request)
        format(TEMPLATE, prompt: generate_text_request.prompt, response: generate_text_request.response_content)
      end
    end
  end
end
