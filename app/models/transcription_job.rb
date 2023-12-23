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
  validates_with ReferencesAudioBlobValidator

  def self.create_for(transcription_service:)
    create!(request: transcription_service.params,
            remote_job_id: transcription_service.job_id,
            status: transcription_service.status,
            active_storage_blob: transcription_service.blob)
  end

  def results
    return if response.blank?

    response.dig('results', 'transcripts')[0]['transcript']
  end
end
