class GenerateImageRequest < ApplicationRecord
  validates :image_name, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :dimensions, inclusion: { in: GenerativeImage::Stability::DIMENSIONS }

  belongs_to :user
  belongs_to :active_storage_blob, optional: true, class_name: 'ActiveStorage::Blob',
                                   inverse_of: :generate_image_request
  has_many :prompts, dependent: :destroy

  def parameterize
    {
      **attributes.slice('style', 'dimensions'),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end
end
