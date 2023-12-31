require 'aws-sdk-bedrockruntime'

module LLMService
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

      def invoke_model_stream(params, &block)
        event_stream_handler = EventStreamHandler.new(&block).to_proc
        invoke_model_with_response_stream(params.merge(event_stream_handler:))
      end
    end
  end
end
