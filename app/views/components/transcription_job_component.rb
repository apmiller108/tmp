class TranscriptionJobComponent < ApplicationViewComponent
  attr_reader :transcription_job, :user

  delegate :status, :completed?, :failed?, to: :transcription_job

  def initialize(transcription_job:, user: current_user)
    @transcription_job = transcription_job
    @user = user
  end

  def status_message
    t('transcription.status', status: transcription_job.status).humanize
  end

  def transcriptions_path
    Rails.application.routes.url_helpers.user_transcription_job_transcriptions_path(user, transcription_job)
  end
end
