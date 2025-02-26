class GenerateImageRequest < ApplicationRecord
  include StatusEnumable
  include Turnable

  store_accessor :options, :style, :aspect_ratio

  validates :image_name, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :aspect_ratio, inclusion: { in: GenerativeImage::Stability::CORE_ASPECT_RATIOS }

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

  before_validation :filter_unknown_style

  OPTION_FIELDS = %w[style aspect_ratio].freeze
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

  def parameterize
    {
      **flat_attributes.slice(*OPTION_FIELDS, *LEGACY_OPTION_FIELDS),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end

  def prompt
    prompts.to_a.find { |p| p.weight.positive? }&.text
  end

  def flat_attributes
    attributes.except('options').merge(options)
  end

  private

  # Removes unknown styles if the LLM gets too creative and adds styles that are not supported by the service
  def filter_unknown_style
    options.delete('style') unless style.in?(GenerativeImage::Stability::STYLE_PRESETS)
  end
end
