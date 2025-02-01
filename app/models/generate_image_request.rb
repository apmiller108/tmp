class GenerateImageRequest < ApplicationRecord
  store_accessor :options, :style, :aspect_ratio

  validates :image_name, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :aspect_ratio, inclusion: { in: GenerativeImage::Stability::CORE_ASPECT_RATIOS }

  belongs_to :user
  belongs_to :active_storage_blob, optional: true, class_name: 'ActiveStorage::Blob',
                                   inverse_of: :generate_image_request
  has_many :prompts, dependent: :destroy

  # Associates the generated images whose blobs are created async via ActionText
  # See also AssociateBlobToGenerateImageRequestJob
  has_many :active_storage_blobs_generate_image_requests, dependent: nil
  has_many :active_storage_blobs, through: :active_storage_blobs_generate_image_requests

  has_one_attached :image

  OPTION_FIELDS = %w[style aspect_ratio].freeze
  LEGACY_OPTION_FIELDS = %w[dimensions].freeze

  def self.generate_name
    timestamp = Time.now.to_i
    random = rand(10_000)
    "genimage_#{timestamp}_#{random}"
  end

  def parameterize
    {
      **flat_attributes.slice(*OPTION_FIELDS, *LEGACY_OPTION_FIELDS),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end

  def flat_attributes
    attributes.except('options').merge(options)
  end
end
