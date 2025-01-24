require 'aws-sdk-bedrockruntime'

class GenerativeText
  module AWS
    class Client
      delegate :invoke_model_with_response_stream, to: :@client

      def initialize
        config = Rails.application.credentials.fetch(:aws)
        @client = Aws::BedrockRuntime::Client.new(
          region: config[:region],
          credentials: Aws::Credentials.new(
            config.fetch(:access_key_id), config.fetch(:secret_access_key)
          )
        )
      end

      def invoke_model_stream(prompt:, **params, &block)
        params[:event_stream_handler] = EventStreamHandler.new(&block).to_proc
        params = InvokeModelRequest.new(prompt:, **params).to_h
        invoke_model_with_response_stream(params)
      rescue Aws::BedrockRuntime::Errors
        raise InvalidRequestError
      end

      def invoke_model(prompt:, **params)
        params = InvokeModelRequest.new(prompt:, **params).to_h
        response = @client.invoke_model(params)
        InvokeModelResponse.new(response.body.read)
      rescue Aws::BedrockRuntime::Errors
        raise InvalidRequestError
      end
    end
  end
end
