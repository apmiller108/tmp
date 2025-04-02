# frozen_string_literal: true

class GenerateTextRequest < ApplicationRecord
  include StatusEnumable
  include Turnable

  TEMPERATURE_VALUES = 0.step(to: 1, by: 0.1).map { _1.round(1) }

  SUPPORTED_MIME_TYPES = %w[image/jpeg image/gif image/png image/webp].freeze
  MAX_FILE_SIZE = 4.megabytes
  has_one_attached :file do |attachable|
    attachable.variant :webp, resize_to_limit: [1024, 768], **ActiveStorage::Blob::WEBP_VARIANT_OPTS, preprocessed: true
  end

  # Stores the raw JSON response from the HTTP request to the LLM
  store_accessor :response

  delegate :content, to: :response, allow_nil: true, prefix: true
  delegate :system_message, to: :generate_text_preset, allow_nil: true, prefix: :preset

  # See also Turable concern for associations to converation
  belongs_to :user, optional: false
  belongs_to :generate_text_preset, optional: true
  has_one :generate_image_request, dependent: :nullify

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 24_000 }
  validates :temperature, inclusion: { in: TEMPERATURE_VALUES }, allow_nil: true
  validates :model, presence: true

  validate :acceptable_file

  before_validation :set_default_model, on: :create
  before_save :convert_to_html

  def conversation
    super || NullConversation.new
  end

  def system_message
    [markdown_format_system_message, preset_system_message].compact.join("\n")
  end

  def response
    @response ||= response_wrapper_class.new(super) if super.present?
  end

  def blobify
    return '' unless completed?

    [
      prompt,
      response.blobify
    ].join(' ')
  end

  def response_token_count
    if completed?
      response.token_count
    else
      0
    end
  end

  # @param [Array<ConversationTurn>] the list of turns to which this belongs
  # @returns [Array<Hash>] A tuple of a user message and assistant response
  def to_turn(turns: [])
    case model.vendor
    when :anthropic
      GenerativeText::Anthropic::Turn.for(self, turns:)
    when :aws
      GenerativeText::AWS::Turn.for(self)
    end
  end

  def model
    GenerativeText::MODELS.find { |m| m.api_name == super }
  end

  def image_capable?
    model.capabilities.image?
  end

  def image_attached?
    file.attached? && file.image?
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
      GenerativeText::AWS::InvokeModelResponse
    end
  end

  def markdown_format_system_message
    GenerativeText::Helpers.markdown_sys_msg if markdown_format?
  end

  def set_default_model
    self.model ||= user.setting.text_model
  end

  def convert_to_html
    if assistant_response_html.nil? && response&.content.present?
      self.assistant_response_html = MarkdownToHtml.call(markdown: response.content)
    end

    self.prompt_html = MarkdownToHtml.call(markdown: prompt) if prompt_html.nil?
  end
end
