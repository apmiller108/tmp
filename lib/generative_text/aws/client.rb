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
        request = GenerateTextRequest.new(prompt:,
                                          model: 'amazon.titan-text-express-v1',
                                          temperature: 0.2)
        params = InvokeModelRequest.new(request, **params).to_h
        invoke_model_with_response_stream(params)
      rescue Aws::BedrockRuntime::Errors
        raise InvalidRequestError
      end

      # @param [GenerateTextRequest] request object
      def invoke_model(generate_text_request)
        params = InvokeModelRequest.new(generate_text_request).to_h
        response = @client.invoke_model(params)
        InvokeModelResponse.new(response.body.read)
      rescue Aws::BedrockRuntime::Errors
        raise InvalidRequestError
      end
    end
  end
end
