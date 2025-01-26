# frozen_string_literal: true

class GenerateTextRequest < ApplicationRecord
  include StatusEnumable

  MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT
    You always answer the with markdown formatting which can inlcude headings,
    bold, italic, links, tables, lists, code blocks, and blockquotes.
  TXT

  TEMPERATURE_VALUES = 0.step(to: 1, by: 0.1).map { _1.round(1) }

  SUPPORTED_MIME_TYPES = %w[image/jpeg image/gif image/png image/webp].freeze
  MAX_FILE_SIZE = 4.megabytes
  has_one_attached :file

  # Stores the raw JSON response from the HTTP request to the LLM
  store_accessor :response

  delegate :content, to: :response, allow_nil: true, prefix: true

  belongs_to :user
  belongs_to :generate_text_preset, optional: true
  belongs_to :conversation, optional: true

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 24_000 }
  validates :temperature, inclusion: { in: TEMPERATURE_VALUES }, allow_nil: true

  validate :acceptable_file

  def conversation
    super || NullConversation.new
  end

  def system_message
    [
      MARKDOWN_FORMAT_SYSTEM_MESSAGE,
      generate_text_preset&.system_message
    ].compact.join("\n")
  end

  def response
    @response ||= response_wrapper_class.new(super) if super.present?
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
    case model.vendor
    when :anthropic
      GenerativeText::Anthropic::Turn.for(self)
    when :aws
      GenerativeText::AWS::Turn.for(self)
    end
  end

  def model
    GenerativeText::MODELS.find { |m| m.api_name == super }
  end

  private

  def acceptable_file
    return unless file.attached?

    validate_file_size
    validate_file_type
    validate_file_for_model
  end

  def validate_file_size
    errors.add(:file, 'must be less that 4 MB') if file.blob.byte_size > MAX_FILE_SIZE
  end

  def validate_file_type
    errors.add(:file, 'must be GIF, JPEG, PNG or WEBP') unless file.blob.content_type.in? SUPPORTED_MIME_TYPES
  end

  def validate_file_for_model
    errors.add(:file, 'is not a capability of this model') unless model.capabilities.image?
  end

  def response_wrapper_class
    case model.vendor
    when :anthropic
      GenerativeText::Anthropic::InvokeModelResponse
    when :aws
      GenerativeText::AWS::Client::InvokeModelResponse
    end
  end
end
