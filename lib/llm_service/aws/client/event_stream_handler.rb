module LLMService
  module AWS
    class Client
      class EventStreamHandler
        def initialize(&block)
          @block = block
        end

        def to_proc
          ->(stream) {
            stream.on_chunk_event(&method(:on_chunk_event))
            stream.on_internal_server_exception_event(&method(:on_exception))
            stream.on_validation_exception_event(&method(:on_exception))
            stream.on_throttling_exception_event(&method(:on_exception))
            stream.on_model_timeout_exception_event(&method(:on_exception))
            stream.on_model_stream_error_exception_event(&method(:on_model_stream_error))
            stream.on_error_event(&method(:on_generic_error))
          }
        end

        def on_chunk_event(event)
          # A series of event bytes will look like this:
          #
          # {"outputText"=>"0..-2 parts of stream", "index"=>0, "totalOutputTextTokenCount"=>nil, "completionReason"=>nil,
          #  "inputTextTokenCount"=>9}
          #
          # {"outputText"=>"final part of stream", "index"=>0, "totalOutputTextTokenCount"=>104, "completionReason"=>"FINISH",
          #  "inputTextTokenCount"=>nil, "amazon-bedrock-invocationMetrics"=>{"inputTokenCount"=>9, "outputTokenCount"=>104,
          #  "invocationLatency"=>3407, "firstByteLatency"=>2440}}
          @block.call(event)
        end

        def on_exception(event)
          raise InvalidRequestError, "#{event.event_type}: #{event.message}"
        end

        def on_model_stream_error(event)
          raise InvalidRequestError, "#{event.event_type}: #{event.message} : #{event.original_message}"
        end

        def on_generic_error(event)
          raise InvalidRequestError, "#{event.event_type}: #{event.error_code} : #{event.error_message}"
        end
      end
    end
  end
end
