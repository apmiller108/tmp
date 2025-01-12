# frozen_string_literal: true

class GenerateTextRequest < ApplicationRecord
  include StatusEnumable

  MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT
    You always answer the with markdown formatting which can inlcude headings,
    bold, italic, links, tables, lists, code blocks, and blockquotes.
  TXT

  # Stores the raw JSON response from the HTTP request to the LLM
  store_accessor :response

  delegate :content, to: :response, allow_nil: true, prefix: true

  belongs_to :user
  belongs_to :generate_text_preset, optional: true
  belongs_to :conversation, optional: true

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 24_000 }

  def conversation
    super || NullConversation.new
  end

  def system_message
    "#{MARKDOWN_FORMAT_SYSTEM_MESSAGE}\n#{generate_text_preset&.system_message}"
  end

  def response
    @response ||= GenerativeText::Anthropic::InvokeModelResponse.new(super) if super.present?
  end

  def response_token_count
    if completed?
      response.token_count
    else
      0
    end
  end

  # @returns [Array<Hash>] A tuple of a user message and assistant response
  def to_turn
    GenerativeText::Anthropic::Turn.for(self)
  end

  def model
    GenerativeText::Anthropic::MODELS.values.find { |m| m.api_name == super }
  end
end
