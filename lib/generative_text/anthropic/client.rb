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

      # rubocop:disable Metrics/AbcSize
      # @return [InvokeModelResponse]
      def invoke_model(prompt:, messages: [], **params)
        model = MODELS.values.find { |m| m.api_name == params[:model] } || DEFAULT_MODEL
        request_body = {
          model: model.api_name,
          max_tokens: model.max_tokens,
          temperature: params[:temperature],
          messages: messages.push(
            {
              role: :user,
              content: [
                type: :text,
                text: prompt
              ]
            }
          )
        }
        request_body[:system] = params[:system_message] if params[:system_message]
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
