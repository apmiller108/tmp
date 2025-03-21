class GenerateImageRequest < ApplicationRecord
  include StatusEnumable
  include Turnable

  store_accessor :options, :style, :aspect_ratio, :request_type, :strength, :quality

  validates :image_name, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :aspect_ratio, inclusion: { in: GenerativeImage::Stability::ASPECT_RATIOS }
  validates :quality, inclusion: { in: GenerativeImage::QUALITY_LEVELS }
  validates :request_type, inclusion: { in: GenerativeImage::REQUEST_TYPES }

  # See also Turable concern for associations to converation
  belongs_to :user
  belongs_to :generate_text_request, optional: true
  has_many :prompts, dependent: :destroy

  # Associates the generated images whose blobs are created async via ActionText
  # See also AssociateBlobToGenerateImageRequestJob
  has_many :active_storage_blobs_generate_image_requests, dependent: :destroy
  has_many :active_storage_blobs, through: :active_storage_blobs_generate_image_requests

  has_one_attached :image do |attachable|
    attachable.variant :webp, resize_to_limit: [1024, 768], **ActiveStorage::Blob::WEBP_VARIANT_OPTS
  end

  # This isn't used yet. Intented for image generation outside the context of a
  # conversation where the base image is associated to the generate_text_request
  has_one_attached :baseimage do |attachable|
    attachable.variant :webp, resize_to_limit: [1024, 768], **ActiveStorage::Blob::WEBP_VARIANT_OPTS
  end

  before_validation :filter_unknown_style

  delegate :image_to_image?, :text_to_image?, :upscale?, to: :request_type

  OPTION_FIELDS = stored_attributes[:options].map(&:to_s)
  LEGACY_OPTION_FIELDS = %w[dimensions].freeze

  def self.generate_name
    timestamp = Time.now.to_i
    random = rand(10_000)
    "genimage_#{timestamp}_#{random}"
  end

  def self.variant_options
    {
      resize_to_limit: [1024, 768],
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end

  # Custom store accessor getter methods
  def quality
    super || GenerativeImage::DEFAULT_QUALITY_LEVEL
  end

  def request_type
    ActiveSupport::StringInquirer.new(super)
  end

  def high_quality_text_to_image?
    text_to_image? && quality == GenerativeImage::HIGH_QUALITY
  end

  def standard_quality_text_to_image?
    text_to_image? && quality == GenerativeImage::STANDARD_QUALITY
  end

  def prompt
    prompts.to_a.find { |p| p.weight.positive? }&.text
  end

  def negative_prompt
    prompts.to_a.find { |p| p.weight.negative? }&.text
  end

  def parameterize
    {
      **flat_attributes.slice(*OPTION_FIELDS, *LEGACY_OPTION_FIELDS),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end

  # The image used in image to image generation
  # @return [ActiveStorage::Attached::One]
  def base_image
    return unless image_modification_request?

    if generate_text_request_id.present?
      generate_text_request.file.variant(:webp).processed.image
    else
      baseimage.variant(:webp).processed.image
    end
  end

  private

  def image_modification_request?
    image_to_image? || upscale?
  end

  def flat_attributes
    attributes.except('options').merge(options)
  end

  # Removes unknown styles if the LLM gets too creative and adds styles that are not supported by the service
  def filter_unknown_style
    options.delete('style') unless style.in?(GenerativeImage::Stability::STYLE_PRESETS)
  end
end
