class TranscriptionRetrievalJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(transcription_job_id)
    transcription_job = TranscriptionJob.find(transcription_job_id)
    remote_job = transcription_job.remote_job

    return log_skipped('transcription already exists') if transcription_job.transcription.present?
    return log_skipped('remote transcription job not finished') unless remote_job.finished?

    if remote_job.completed?
      get_and_create_transcription(transcription_job, remote_job)
    elsif remote_job.failed?
      transcription_job.update!(response: { failure_reason: remote_job.failure_reason },
                                status: remote_job.status)
    end

    broadcast_blob(transcription_job)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : transcription_job_id: #{transcription_job_id}")
  end

  private

  def log_skipped(message)
    Rails.logger.warn("#{self.class}: skipped job : #{message}")
  end

  def get_and_create_transcription(transcription_job, remote_job)
    response = TranscriptionService.get_transcription(remote_job.transcript_file_uri)
    transcription_job.update!(response:, status: remote_job.status)
    Transcription.create!(
      transcription_job:,
      content: transcription_job.results,
      active_storage_blob_id: transcription_job.active_storage_blob_id
    )
  end

  def broadcast_blob(transcription_job)
    blob = transcription_job.active_storage_blob
    user = blob.memo.user
    ViewComponentBroadcaster.call([user, TurboStreams::STREAMS[:blobs]],
                                  component: BlobComponent.new(blob:, user:), action: :replace)
  end
end
