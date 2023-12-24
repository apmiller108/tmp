class TranscriptionDeletionJob
  include Sidekiq::Job

  def perform(remote_job_id)
    TranscriptionService.new.delete_batch_transcription_job(remote_job_id)
  rescue TranscriptionService::InvalidRequestError => e
    # This error will happen if the job no longer exists, which is expected as
    # batch jobs are automatically deleted after some time by service provider.
    Rails.logger.warn "#{self.class}: #{e} : remote_job_id: #{remote_job_id}"
  end
end
