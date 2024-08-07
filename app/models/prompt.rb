class Prompt < ApplicationRecord
  MAX_LENGTH = 300

  belongs_to :generate_image_request

  validates :text, presence: true
  validates :weight, presence: true, inclusion: { in: -10..10 }

  before_validation :truncate_text

  def parameterize
    attributes.slice('text', 'weight')
  end

  private

  def truncate_text
    return if text.blank?

    self.text = text[0, MAX_LENGTH]
  end
end
