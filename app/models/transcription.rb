class Transcription < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  belongs_to :transcription_job

  validates_with ReferencesAudioBlobValidator
end
