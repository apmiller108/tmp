class GenerateImageRequest < ApplicationRecord
  validates :image_id, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS.keys, allow_blank: true }
  validates :dimensions, inclusion: { in: GenerativeImage::Stability::DIMENSIONS }

  has_many :prompts
end
