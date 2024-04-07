class GenerativeText
  module Anthropic
    VERSION = '2023-06-01'.freeze
    HOST = 'https://api.anthropic.com/'
    MESSAGES_PATH = '/v1/messages'.freeze
    HAIKU = 'claude-3-haiku-20240307'.freeze
    SONNET = 'claude-3-sonnet-20240229'.freeze
    MAX_TOKENS = 1024 # 4096 is the max output

    class Client
      def initialize
      end

      # @return [InvokeModelResponse]
      def invoke_model(prompt:, **params)
        request_body = {
          model: HAIKU,
          max_tokens: MAX_TOKENS,
          temperature: params[:temp], # TODO: this should be bound to the preset/system message
          system: params[:system_message], # TODO combine with temperature
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
        JSON.parse(response.body)
      end

      # yield block to [InvokeModelStreamResponse]
      def invoke_model_stream(prompt:, **params, &block)
      end

      private

      def conn
        Faraday.new(
          url: HOST,
          headers: {
            'x-api-key': Rails.application.credentials.fetch(:anthropic_key),
            'Content-Type': 'application/json',
            'anthropic-version': VERSION
          }
        ) do |f|
          # f.response :raise_error
        end
      end
    end
  end
end
