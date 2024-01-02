# frozen_string_literal: true

class TranscriptionComponent < ApplicationViewComponent
  attr_reader :transcription

  delegate :status, to: :transcription_job
  delegate :content, :diarized_results, :active_storage_blob, :transcription_job, to: :transcription

  def initialize(transcription:)
    @transcription = transcription
  end

  def transcription_dom_id
    dom_id(transcription)
  end

  def text_dom_id
    "transcription_text_#{transcription.id}"
  end

  def speakers_dom_id
    "transcription_speakers_#{transcription.id}"
  end

  def summary_dom_id
    "transcription_summary_#{transcription.id}"
  end

  def download_path
    user_transcription_download_path(current_user, transcription_id: transcription.id)
  end

  def filename
    active_storage_blob.filename
  end
end
