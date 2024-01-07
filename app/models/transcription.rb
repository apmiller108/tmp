class Transcription < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  belongs_to :transcription_job
  has_one :summary, as: :summarizable, dependent: :destroy

  validates_with ReferencesAudioBlobValidator

  delegate :items, to: :transcription_job
  delegate :speakers, to: :speaker_content

  def diarized_results
    speaker_content.squash
  end

  def diarized_results_to_text
    diarized_results.map(&:to_text).join("\n")
  end

  def speaker_content
    @speaker_content ||= SpeakerContent.new(items)
  end

  def to_text
    [content_section, speaker_id_section, summary_section].compact.join("\n\n")
  end

  private

  def content_section
    <<~TEXT.strip
      Text:

      #{content}
    TEXT
  end

  def speaker_id_section
    <<~TEXT.strip
      Speaker ID:

      #{diarized_results_to_text}
    TEXT
  end

  def summary_section
    return unless summary

    <<~TEXT.strip
      Summary:

      #{summary.content}
    TEXT
  end
end
