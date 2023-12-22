class TranscriptionService
  module AWS
    class Client
      class BatchTranscription
        def self.call(client, blob, **options)
          new(client, blob).batch_transcribe(**options)
        end

        attr_reader :blob, :client, :request, :response

        def initialize(client, blob)
          @client = client
          @blob = blob
        end

        def batch_transcribe(**options)
          @request = BatchTranscriptionRequest.new(blob, **options)
          @response = BatchTranscriptionResponse.new(
            client.start_transcription_job(request.params)
          )
          self
        end
      end
    end
  end
end
