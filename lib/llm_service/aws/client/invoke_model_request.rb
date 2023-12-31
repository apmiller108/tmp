module LLMService
  module AWS
    class Client
      class InvokeModelRequest
        MAX_TOKENS = 512
        TEMP = 0.2
        TOP_P = 0.8

        attr_reader :params

        def initialize(prompt:, **params)
          @prompt = prompt
          @params = params
        end

        def to_h
          {
            model_id: TITAN_EXPRESS,
            content_type: 'application/json',
            accept: 'application/json',
            body:
          }
        end

        private

        def body
          {
            'inputText' => @prompt,
            'textGenerationConfig' => text_gen_config
          }.to_json
        end

        def text_gen_config
          {
            'maxTokenCount' => params.fetch(:max_tokens, MAX_TOKENS),
            'stopSequences' => params.fetch(:stop_sequences, []),
            'temperature' => params.fetch(:temp, TEMP),
            'topP' => params.fetch(:top_p, TOP_P)
          }
        end
      end
    end
  end
end
