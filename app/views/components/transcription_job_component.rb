class TranscriptionJobComponent < ApplicationViewComponent
  attr_reader :transcription_job

  delegate :status, :completed?, :failed?, to: :transcription_job

  def initialize(transcription_job:)
    @transcription_job = transcription_job
  end

  def status_message
    t('transcription.status', status: transcription_job.status).humanize
  end

  def transcriptions_path
    user_transcription_job_transcriptions_path(current_user, transcription_job)
  end
end
