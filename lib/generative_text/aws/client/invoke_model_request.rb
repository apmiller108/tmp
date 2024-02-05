class GenerativeText
  module AWS
    class Client
      class InvokeModelRequest
        MAX_TOKENS = 1000 # Seems to be max output tokens only. Supports up to 8k.
        TEMP = 0.2 # Between 0..1. Increase for more randomness.
        TOP_P = 0.8 # Between 0..1. Only consider possibilities gte this value.

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
          }.merge(event_stream_options)
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

        def event_stream_options
          return {} if params[:event_stream_handler].blank?

          {
            event_stream_handler: params[:event_stream_handler]
          }
        end
      end
    end
  end
end
