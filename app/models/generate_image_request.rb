class GenerateImageRequest < ApplicationRecord
  validates :image_name, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :dimensions, inclusion: { in: GenerativeImage::Stability::DIMENSIONS }

  belongs_to :user
  belongs_to :active_storage_blob, optional: true, class_name: 'ActiveStorage::Blob',
                                   inverse_of: :generate_image_request
  has_many :prompts, dependent: :destroy
  has_many :active_storage_blobs_generate_image_requests, dependent: nil
  has_many :active_storage_blobs, through: :active_storage_blobs_generate_image_requests

  has_one_attached :image

  def parameterize
    {
      **attributes.slice('style', 'dimensions'),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end
end
