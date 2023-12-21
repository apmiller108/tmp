class TranscriptionJob < ApplicationRecord
  belongs_to :active_storage_blob
  has_one :transcription, dependent: :destroy

  validates_with ReferencesAudioBlobValidator

  enum :status, {
         created: 'created',
         queued: 'queued',
         in_progress: 'in_progress',
         failed: 'failed',
         completed: 'completed'
       }, default: :new

  def results
    response.dig('results', 'transcripts')[0]['transcript']
  end
end
