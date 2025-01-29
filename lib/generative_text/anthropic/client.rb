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
          f.response :raise_error
          # f.response :logger, nil, { bodies: { request: true, response: false } } # Log request and response to stdout
        end
      end

      # @return [InvokeModelResponse]
      def invoke_model(generate_text_request)
        response = conn.post(MESSAGES_PATH) do |req|
          req.body = InvokeModelRequest.new(generate_text_request).to_json
        end
        InvokeModelResponse.new(response.body)
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      attr_reader :conn
    end
  end
end
