class TranscriptionRetrievalJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(transcription_job_id)
    transcription_job = TranscriptionJob.find(transcription_job_id)
    return log_skipped('transcription already exists') if transcription_job.transcription.present?

    client = TranscriptionService::AWS::Client.new
    remote_job = TranscriptionService.new(client).get_batch_transcribe_job(transcription_job.remote_job_id)
    return log_skipped('remote transcription job not finished') unless remote_job.finished?

    if remote_job.completed?
      response = TranscriptionService.get_transcription(remote_job.transcript_file_uri)
      transcription_job.update!(response:, status: remote_job.status)
      Transcription.create!(
        transcription_job:,
        content: transcription_job.results,
        active_storage_blob_id: transcription_job.active_storage_blob_id
      )
    elsif remote_job.failed?
      response = { failure_reason: remote_job.failure_reason }
      transcription_job.update!(response:, status: remote_job.status)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : transcription_job_id: #{transcription_job_id}")
  end

  private

  def log_skipped(message)
    Rails.logger.warn("#{self.class}: skipped job : #{message}")
  end
end
