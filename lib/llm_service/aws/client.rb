require 'aws-sdk-bedrockruntime'

class LLMService
  module AWS
    class Client
      delegate :invoke_model, :invoke_model_with_response_stream, to: :@client

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
        params.merge!(event_stream_handler: EventStreamHandler.new(&block).to_proc)
        params = InvokeModelRequest.new(prompt:, **params).to_h
        invoke_model_with_response_stream(params)
      end
    end
  end
end
