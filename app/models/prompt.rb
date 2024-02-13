class Prompt < ApplicationRecord
  MAX_LENGTH = 300

  belongs_to :generate_image_request

  validates :text, presence: true, length: { maximum: MAX_LENGTH } # Stability max is 77 tokens
  validates :weight, presence: true, inclusion: { in: -10..10 }

  before_validation :truncate_text

  private

  def truncate_text
    return if text.blank?

    self.text = text[0, MAX_LENGTH]
  end
end
