class TranscriptionSummaryComponent < ApplicationViewComponent
  attr_reader :transcription

  delegate :summary, to: :transcription
  delegate :content, :completed?, :created?, :queued?, :in_progress?, :failed?,
           to: :summary, allow_nil: true

  def self.id(transcription:)
    "transcription_summary_#{transcription.id}"
  end

  def initialize(transcription:)
    @transcription = transcription
  end

  def id
    self.class.id(transcription:)
  end

  def formatted_content
    MarkdownToHtml.call(markdown: content)
  end

  def generating_summary?
    created? || queued? || (in_progress? && content.blank?)
  end
end
