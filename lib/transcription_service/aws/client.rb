require 'aws-sdk-transcribeservice'

class TranscriptionService
  module AWS
    class Client
      attr_reader :operation

      delegate :request, :response, :blob, to: :operation, allow_nil: true
      delegate_missing_to :client

      def initialize
        @config = Rails.application.credentials.fetch(:aws)
      end

      def batch_transcribe(blob, **options)
        @operation = BatchTranscription.call(self, blob, **options)
      rescue Aws::TranscribeService::Errors::ConflictException
        raise InvalidRequestError
      end

      def get_batch_transcribe_job(job_id)
        @operation = BatchTranscriptionResponse.new(
          get_transcription_job(transcription_job_name: job_id)
        )
      end

      def delete_batch_transcription_job(job_id)
        delete_transcription_job(transcription_job_name: job_id)
      rescue Aws::TranscribeService::Errors::BadRequestException
        raise InvalidRequestError
      end

      private

      attr_reader :config

      def client
        @client ||= Aws::TranscribeService::Client.new(
          region: config[:region],
          credentials: Aws::Credentials.new(
            config.fetch(:access_key_id), config.fetch(:secret_access_key)
          )
        )
      end
    end
  end
end
