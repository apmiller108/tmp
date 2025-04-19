require 'aws-sdk-transcribeservice'

class TranscriptionService
  module AWS
    class Client
      attr_reader :operation

      delegate :request, :response, :blob, to: :operation, allow_nil: true
      delegate_missing_to :@client

      def initialize
        @client = Aws::TranscribeService::Client.new(
          region: ENV.fetch('AWS_REGION'),
          credentials: Aws::Credentials.new(
            ENV.fetch('AWS_ACCESS_KEY'), ENV.fetch('AWS_SECRET_KEY')
          )
        )
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
    end
  end
end
