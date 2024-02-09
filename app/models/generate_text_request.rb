class GenerateTextRequest < ApplicationRecord
  belongs_to :user

  validates :text_id, :prompt, presence: true
end
