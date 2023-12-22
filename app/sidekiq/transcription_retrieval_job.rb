class TranscriptionRetrievalJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(transcription_job_id)
    transcription_job = TranscriptionJob.find(transcription_job_id)
  end
end
