class TranscriptionSummaryComponent < ApplicationViewComponent
  attr_reader :transcription

  delegate :summary, to: :transcription
  delegate :bullet_points?, :bullet_points, :content, :completed?, :created?, :queued?, :in_progress?,
           to: :summary, allow_nil: true

  def initialize(transcription:)
    @transcription = transcription
  end

  def id
    if summary
      dom_id(summary)
    else
      "no_summary_#{transcription.id}"
    end
  end

  def generating_summary?
    created? || queued? || in_progress?
  end
end
