module Gemini
  class Client
    # include ErrorHandling # To be implemented

    def initialize
      @api_key = ENV.fetch('GEMINI_API_KEY')
      @conn = Faraday.new(
        url: HOST,
        headers: {
          'Content-Type': 'application/json'
        }
      ) do |f|
        f.adapter :typhoeus
      end
    end

    # @param generate_text_request [GenerateTextRequest]
    # @return [InvokeModelResponse]
    def invoke_model(generate_text_request)
      model = generate_text_request.model.api_name
      url = "/#{VERSION}/models/#{model}:generateContent?key=#{@api_key}"

      req_body = InvokeModelRequest.new(generate_text_request).to_json

      response = conn.post(url) do |req|
        req.body = req_body
      end

      if response.status.in?(200..299)
        InvokeModelResponse.new(response.body)
      else
        raise ClientError, "Gemini API Error: #{response.status} - #{response.body}"
      end
    end

    # Stream responses from the Gemini API
    # @param generate_text_request [GenerateTextRequest]
    # @yield [String] Yields chunks of the assistant response
    # @return [InvokeModelResponse] Returns the complete response when done
    def invoke_model_stream(generate_text_request, &block)
      model = generate_text_request.model.api_name
      url = "/#{VERSION}/models/#{model}:streamGenerateContent?alt=sse&key=#{@api_key}"

      stream_response = StreamResponse.new
      req_body = InvokeModelRequest.new(generate_text_request, stream: true).to_json

      response = conn.post(url) do |req|
        req.body = req_body
        req.options.on_data = lambda do |chunk, _received_bytes|
          process_stream_chunk(chunk, stream_response, &block)
        end
      end

      if response.status.in?(200..299)
        InvokeModelResponse.new(stream_response.to_response_format.to_json)
      else
        raise ClientError, "Gemini API Error: #{response.status} - #{response.body}"
      end
    end

    private

    attr_reader :conn

    def process_stream_chunk(chunk, stream_response, &block)
      chunk.split("\n\n").each do |raw_event|
        event = StreamEvent.parse(raw_event)
        next unless event

        stream_response.update(event)
        block.call(event.text_content) if event.text?
      end
    end
  end
end
