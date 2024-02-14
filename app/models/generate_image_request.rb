class GenerateImageRequest < ApplicationRecord
  validates :image_id, presence: true, length: { maximum: 50 }
  validates :style, inclusion: { in: GenerativeImage::Stability::STYLE_PRESETS, allow_blank: true }
  validates :dimensions, inclusion: { in: GenerativeImage::Stability::DIMENSIONS }

  belongs_to :user
  has_many :prompts, dependent: :destroy

  def parameterize
    {
      **attributes.slice('style', 'dimensions'),
      prompts: prompts.map(&:parameterize)
    }.symbolize_keys
  end
end
