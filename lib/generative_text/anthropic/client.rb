class GenerativeText
  module Anthropic
    class Client
      def initialize
        @conn = Faraday.new(
          url: HOST,
          headers: {
            'x-api-key': Rails.application.credentials.fetch(:anthropic_key),
            'Content-Type': 'application/json',
            'anthropic-version': VERSION
          }
        ) do |f|
          f.adapter :typhoeus
          f.response :raise_error
          # f.response :logger, nil, { bodies: { request: true, response: false } } # Log request and response to stdout
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
      # @yield [String] Yields chunks of the assistant response
      # @return [InvokeModelResponse] Returns the complete response when done
      def invoke_model_stream(generate_text_request, &block)
        stream_response = StreamResponse.new

        conn.post(MESSAGES_PATH) do |req|
          req.body = InvokeModelRequest.new(generate_text_request, stream: true).to_json
          req.options.on_data = proc do |chunk, _|
            chunk.split("\n\n").each do |event|
              event_type = nil
              event_data = nil

              event.split("\n").each do |line|
                if line.start_with?('event: ')
                  event_type = line.sub(/^event: /, '')
                elsif line.start_with?('data: ')
                  event_data = line.sub(/^data: /, '')
                end
              end

              next if event_type.nil? || event_data.nil? || event_type == 'ping'

              data = JSON.parse(event_data)
              stream_response.update(event_type:, event_data: data)

              if (event_type == 'content_block_start' && data.dig('content_block', 'type') == 'text') ||
                 (event_type == 'content_block_delta' && data.dig('delta', 'type') == 'text_delta')
                text = data.dig('content_block', 'text') || data.dig('delta', 'text')
                block.call(text)
              end
            end
          end
        end

        InvokeModelResponse.new(stream_response.to_response_format)
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      attr_reader :conn
    end
  end
end
