class GenerateTextRequest < ApplicationRecord
  belongs_to :user

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 8000 }
end
