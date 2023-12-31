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
        event_stream_handler =  ->(stream) {
          stream.on_chunk_event do |e|
            # {"outputText"=>"0..-2 parts of stream", "index"=>0, "totalOutputTextTokenCount"=>nil, "completionReason"=>nil,
            #  "inputTextTokenCount"=>9}
            # {"outputText"=>"final part of stream", "index"=>0, "totalOutputTextTokenCount"=>104, "completionReason"=>"FINISH",
            #  "inputTextTokenCount"=>nil, "amazon-bedrock-invocationMetrics"=>{"inputTokenCount"=>9, "outputTokenCount"=>104,
            #  "invocationLatency"=>3407, "firstByteLatency"=>2440}}
            block.call(e.bytes)
          end
          stream.on_internal_server_exception_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.message}"
          end
          stream.on_model_stream_error_exception_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.message} : #{e.original_message}"
          end
          stream.on_validation_exception_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.message}"
          end
          stream.on_throttling_exception_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.message}"
          end
          stream.on_model_timeout_exception_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.message}"
          end
          stream.on_error_event do |e|
            raise InvalidRequestError, "#{e.event_type}: #{e.erro_code} : #{e.error_message}"
          end
        }
        invoke_model_with_response_stream(params.merge(event_stream_handler:))
      end
    end
  end
end
