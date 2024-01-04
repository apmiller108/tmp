class TranscriptionJob < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  has_one :transcription, dependent: :destroy

  enum :status, {
    created: 'created',
    queued: 'queued',
    in_progress: 'in_progress',
    failed: 'failed',
    completed: 'completed'
  }

  validates :status, inclusion: { in: statuses.values, message: "%<value>s must be one of #{statuses.values}" }
  validates :remote_job_id, presence: true
  validates_with ReferencesAudioBlobValidator

  after_destroy_commit :remove_remote_batch_transcription_job

  scope :unfinished, -> { where.not(status: %i[failed completed]) }

  def self.create_for(transcription_service:)
    create!(request: transcription_service.params,
            remote_job_id: transcription_service.job_id,
            status: transcription_service.status,
            active_storage_blob: transcription_service.blob)
  end

  def results
    return {} if response.blank?

    response.dig('results', 'transcripts')[0]['transcript']
  end

  def items
    return [] if response.blank?

    response.dig('results', 'items')
  end

  def remote_job
    @remote_job ||= TranscriptionService.new(
      TranscriptionService::AWS::Client.new
    ).get_batch_transcribe_job(remote_job_id)
  end

  private

  def remove_remote_batch_transcription_job
    TranscriptionDeletionJob.perform_async(remote_job_id)
  end
end
