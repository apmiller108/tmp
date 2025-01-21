# frozen_string_literal: true

class GenerateTextRequest < ApplicationRecord
  include StatusEnumable

  MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT
    You always answer the with markdown formatting which can inlcude headings,
    bold, italic, links, tables, lists, code blocks, and blockquotes.
  TXT

  TEMPERATURE_VALUES = 0.step(to: 1, by: 0.1).map { _1.round(1) }

  SUPPORTED_MIME_TYPES = %w[image/jpeg image/gif image/png/ image/webp].freeze
  has_one_attached :file do |attachable|
    attachable.variant :for_display, { resize_to_limit: [1920, 1920],
                                       preprocessed: true,
                                       **ActiveStorage::Blob::WEBP_VARIANT_OPTS }
  end
  before_save :optimize_image, if: -> { file.attached? && file_changed? && file.blob.image? }

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

  private

  def acceptable_file
    return unless file.attached?

    errors.add(:file, 'must be less that 10 MB') if file.blob.byte_size > 10.megabytes
    errors.add(:file, 'must be GIF, JPEG, PNG or WEBP') unless file.blob.content_type.in? SUPPORTED_MIME_TYPES
  end

  def optimize_image
    return unless file.blob.image?

    processed_image = file.variant(
      resize_to_limit: [1920, 1920],
      saver: {
        strip: true,
        quality: 80
      }
    ).processed

    file.attach(processed_image.blob)
  end
end
