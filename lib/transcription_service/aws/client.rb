require 'aws-sdk-transcribeservice'

class TranscriptionService
  module AWS
    class Client
      attr_reader :request, :response

      def initialize(**options)
        @options = options
        @config = Rails.application.credentials.fetch(:aws)
      end

      def batch_transcribe(blob)
        @blob = blob
        @response = BatchTranscriptionResponse.new(
          client.start_transcription_job(request.params)
        )
      end

      def request
        @request ||= BatchTranscriptionRequest.new(blob, **options)
      end

      private

      attr_reader :config, :blob, :options

      def client
        @client = Aws::TranscribeService::Client.new(
          region: config[:region],
          credentials: Aws::Credentials.new(
            config.fetch(:access_key_id), config.fetch(:secret_access_key)
          )
        )
      end
    end
  end
end
