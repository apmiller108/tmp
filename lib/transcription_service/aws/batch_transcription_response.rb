class TranscriptionService
  module AWS
    class BatchTranscriptionResponse
      attr_reader :start_job_response

      delegate :transcription_job, to: :start_job_response
      delegate :transcription_job_name, :transcription_job_status, to: :transcription_job
      alias job_id transcription_job_name

      def initialize(start_job_response)
        @start_job_response = start_job_response
      end

      def status
        TranscriptionJob.statuses[transcription_job_status.downcase]
      end
    end
  end
end
