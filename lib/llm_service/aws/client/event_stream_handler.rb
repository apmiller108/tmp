class LLMService
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
          @block.call(InvokeModelStreamResponse.new(event.bytes))
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
