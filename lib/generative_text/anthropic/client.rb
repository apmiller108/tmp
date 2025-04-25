class GenerativeText
  module Anthropic
    class Client
      def initialize
        @conn = Faraday.new(
          url: HOST,
          headers: {
            'x-api-key': ENV.fetch('ANTHROPIC_KEY'),
            'Content-Type': 'application/json',
            'anthropic-version': VERSION
          }
        ) do |f|
          f.adapter :typhoeus
          f.response :raise_error
          # f.response :logger, nil, { bodies: { request: true, response: true } } # Log request and response to stdout
        end
      end

      # @param generate_text_request [GenerateTextRequest]
      # @return [InvokeModelResponse]
      def invoke_model(generate_text_request)
        response = conn.post(MESSAGES_PATH) do |req|
          req.body = InvokeModelRequest.new(generate_text_request).to_json
        end
        InvokeModelResponse.new(response.body)
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      # Stream responses from the Anthropic API
      # @param generate_text_request [GenerateTextRequest]
      # @yield [String] Yields chunks of the assistant response only (not the event or tool use responses)
      # @return [InvokeModelResponse] Returns the complete response when done
      def invoke_model_stream(generate_text_request, &block)
        stream_response = StreamResponse.new

        conn.post(MESSAGES_PATH) do |req|
          req.body = InvokeModelRequest.new(generate_text_request, stream: true).to_json
          req.options.on_data = lambda do |chunk, _received_bytes|
            process_stream_chunk(chunk, stream_response, &block)
          end
        end

        InvokeModelResponse.new(stream_response.to_response_format)
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      attr_reader :conn

      def process_stream_chunk(chunk, stream_response, &block)
        chunk.split("\n\n").each do |raw_event|
          event = StreamEvent.parse(raw_event)
          next unless event

          stream_response.update(event)

          # block only yielded to for text (not tool use JSON or anything else)
          block.call(event.text_content) if event.text?
        end
      end
    end
  end
end
