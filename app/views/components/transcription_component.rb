# frozen_string_literal: true

class TranscriptionComponent < ApplicationViewComponent
  attr_reader :transcription_job

  delegate :status, :transcription, to: :transcription_job
  delegate :content, to: :transcription, allow_nil: true, prefix: true

  def initialize(transcription_job:)
    @transcription_job = transcription_job
  end

  def transcription_dom_id
    transcription.present? ? dom_id(transcription) : 'no-transcription'
  end

  def completed_transcription?
    transcription_job.completed? && transcription.present?
  end
end
