class GenerateTextRequest < ApplicationRecord
  belongs_to :user
  belongs_to :generate_text_preset, optional: true
  belongs_to :conversation, optional: true

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 8000 }

  delegate :system_message, to: :generate_text_preset, allow_nil: true
end
