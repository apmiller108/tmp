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
        end
      end

      # @return [InvokeModelResponse]
      def invoke_model(prompt:, **params)
        request_body = {
          model: HAIKU,
          max_tokens: MAX_TOKENS,
          temperature: params[:temp], # TODO: this should be bound to the preset/system message
          system: params[:system_message], # TODO: combine with temperature
          messages: [
            {
              role: :user,
              content: [
                type: :text,
                text: prompt
              ]
            }
          ]
        }
        response = conn.post(MESSAGES_PATH) do |req|
          req.body = request_body.to_json
        end
        InvokeModelResponse.new(response.body)
      rescue Faraday::ClientError => e
        raise ClientError, "#{e.response_status}: #{e.response_body}"
      end

      private

      attr_reader :conn
    end
  end
end
