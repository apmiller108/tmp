class Transcription < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  belongs_to :transcription_job

  validates_with ReferencesAudioBlobValidator

  delegate :items, to: :transcription_job

  def diarized_results
    SpeakerContent.new(items).squash
  end
end
