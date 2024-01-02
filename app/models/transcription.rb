class Transcription < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  belongs_to :transcription_job
  has_one :summary, as: :summarizable, dependent: :destroy

  validates_with ReferencesAudioBlobValidator

  delegate :items, to: :transcription_job

  def diarized_results
    SpeakerContent.new(items).squash
  end

  def to_text
    <<~TEXT
      Text:

      #{content}

      Speaker ID:

      #{diarized_results.map(&:to_text).join("\n")}
    TEXT
  end
end
