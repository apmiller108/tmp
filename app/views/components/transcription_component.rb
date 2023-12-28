# frozen_string_literal: true

class TranscriptionComponent < ApplicationViewComponent
  attr_reader :transcription_job

  delegate :status, :transcription, :active_storage_blob, to: :transcription_job
  delegate :content, :diarized_results, to: :transcription, allow_nil: true

  def initialize(transcription_job:)
    @transcription_job = transcription_job
  end

  def transcription_dom_id
    transcription.present? ? dom_id(transcription) : 'no-transcription'
  end

  def text_dom_id
    "transcription_text_#{transcription.id}"
  end

  def speakers_dom_id
    "transcription_speakers_#{transcription.id}"
  end

  # Presentation friendly speaker name
  #
  # @param [String] spk_0, spk_1, ...etc
  # @return [String]
  def speaker_from_label(label)
    speaker_num = label.split('_').last.to_i + 1
    "Speaker #{speaker_num}: "
  end

  def completed_transcription?
    transcription_job.completed? && transcription.present?
  end

  def filename
    active_storage_blob.filename
  end
end
