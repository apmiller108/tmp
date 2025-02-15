class ConversationTurn < ApplicationRecord
  TURNABLE_TYPES = %w[GenerateTextRequest GenerateImageRequest].freeze

  belongs_to :conversation
  belongs_to :turnable, polymorphic: true, dependent: :destroy

  scope :text_requests, -> { where(turnable_type: 'GenerateTextRequest') }
  scope :image_requests, -> { where(turnable_type: 'GenerateImageRequest') }

  validates :turnable_type, inclusion: { in: TURNABLE_TYPES }

  def text?
    turnable_type == 'GenerateTextRequest'
  end

  def image?
    turnable_type == 'GenerateImageRequest'
  end

  def generated_image?
    image? && turnable.image.attached?
  end
end
