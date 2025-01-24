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

      # rubocop:disable Metrics/AbcSize
      # @return [InvokeModelResponse]
      def invoke_model(generate_text_request)
        model = generate_text_request.model
        messages = generate_text_request.conversation.exchange
        request_body = {
          model: model.api_name,
          max_tokens: model.max_tokens,
          temperature: generate_text_request.temperature,
          messages: messages.push(
            {
              role: :user,
              content: [
                type: :text,
                text: generate_text_request.prompt
              ]
            }
          )
        }
        request_body[:system] = generate_text_request.system_message if generate_text_request.system_message
        response = conn.post(MESSAGES_PATH) do |req|
          req.body = request_body.to_json
        end
        InvokeModelResponse.new(response.body)
      rescue Faraday::Error => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :conn
    end
  end
end
