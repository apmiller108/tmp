class TranscriptionService
  module AWS
    class BatchTranscriptionResponse
      attr_reader :start_job_response

      delegate :transcription_job, to: :start_job_response
      delegate :transcription_job_name, :transcription_job_status, :transcript, to: :transcription_job
      delegate :transcript_file_uri, to: :transcript, allow_nil: true
      alias job_id transcription_job_name

      def initialize(start_job_response)
        @start_job_response = start_job_response
      end

      def status
        TranscriptionJob.statuses[transcription_job_status.downcase]
      end

      def completed?
        status == TranscriptionJob.statuses[:completed]
      end
    end
  end
end
