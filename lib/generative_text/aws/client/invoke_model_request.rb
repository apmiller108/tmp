class GenerativeText
  module AWS
    class Client
      class InvokeModelRequest
        TOP_P = 0.8 # Between 0..1. Only consider possibilities gte this value. Lower it for weirdness.

        attr_reader :generate_text_request

        delegate :model, :prompt, :temperature, to: :generate_text_request

        def initialize(generate_text_request, **opts)
          @generate_text_request = generate_text_request
          @opts = opts
        end

        def to_h
          {
            model_id: model.api_name,
            content_type: 'application/json',
            accept: 'application/json',
            body:
          }.merge(event_stream_options)
        end

        private

        def body
          {
            'inputText' => prompt,
            'textGenerationConfig' => text_gen_config
          }.to_json
        end

        def text_gen_config
          {
            'maxTokenCount' => model.max_tokens,
            'stopSequences' => @opts.fetch(:stop_sequences, []),
            'temperature' => temperature,
            'topP' => @opts.fetch(:top_p, TOP_P)
          }
        end

        def event_stream_options
          return {} if @opts[:event_stream_handler].blank?

          {
            event_stream_handler: @opts[:event_stream_handler]
          }
        end
      end
    end
  end
end
